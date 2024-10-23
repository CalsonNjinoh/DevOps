"use strict";
const populateSheet = require("./Spreadsheets/xlsx-utils");
const FormSpreadsheet = require("./Spreadsheets/FormSpreadsheet");

const {MongoClient, ObjectId} = require("mongodb");
const toCsv = require("csv-write-stream");
const fjMap = require("fj-map");
const prop = require("prop");
const fs = require("fs");
const path = require("path");
const sanitize = require("sanitize-filename");
const mkdirp = require("mkdirp");
const xlsx = require("xlsx-populate");
const AWS = require("aws-sdk");
const archiver = require("archiver");
const rimraf = require("rimraf");


const ORG = process.env.ORG ? ObjectId(process.env.ORG) : null;
const WORKFLOW = process.env.WORKFLOW ? ObjectId(process.env.WORKFLOW) : null;
const BUCKETORG = process.env.BUCKETORG;
const MONGO = process.env.MONGO;
const BUCKET = process.env.BUCKET;
const ENV = process.env.ENV || "development";

const ROOT_DIR = "/tmp/9Meters";

const START_DAY = -21;
const TARGET_DAY = -7;
const DAY_DIFFERENCE = Math.abs(START_DAY - TARGET_DAY);

const MAP_CSV = ["Key", "Localized", "Values"];

const DEANON_HEADER = [
	"AnonId",
	"FirstName",
	"LastName"
];

let END_DATE;

exports.handler = async (event) => {

	if(!ORG || !WORKFLOW || !BUCKETORG || !MONGO || !BUCKET) 
		throw new Error("Missing environment variables");

	await removeDirectory(ROOT_DIR);

	END_DATE = event.time ? new Date(event.time) : new Date();
	END_DATE.setMinutes(59);
	END_DATE.setHours(23);
	END_DATE.setSeconds(59);

	const client = new MongoClient(MONGO);

	let db, connectedClient;
	try {
		connectedClient = await client.connect();
		db = connectedClient.db("aetonix");
		await run(db);
		await finish();
	} catch (e){
		console.error(e);
	}

	return connectedClient.close();
}

async function finish(){
	const outDir = path.resolve(`/tmp/9Meters_${formatFileDate(END_DATE)}.zip`);
	
	try {
		await zipDirectory(ROOT_DIR, outDir);

		if (ENV !== 'development') {
			const params = { Bucket: BUCKET, Key: `${BUCKETORG}/${outDir.substring(5)}`, Body: fs.readFileSync(outDir) };
			return s3Upload(params);
		}
	} catch (error) {
		console.log(error);
	}
}

async function run(db){
	createDirectory(ROOT_DIR);
	
	const orgGroups = await getOrgGroups(db, ORG);

	for(const orgGroup of orgGroups){
		const rootDir = ROOT_DIR;
		createDirectory(rootDir);
		console.log(orgGroup.name);
		await generateAllCSV(db, orgGroup._id, orgGroup.name, rootDir);
		await createDeAnonMap(db, orgGroup._id, orgGroup.name, rootDir);
	}

	return orgGroups;
}

async function createDeAnonMap(db, groupId, groupName, rootDir){
	const anonName = path.join(rootDir, `${sanitize(groupName)}-De-Anonymize_Map.xlsx`);

	const patients = await getPatientsIds(db, groupId);
	const results = await Promise.all(patients.map(person => getPersonData(db, ObjectId(person._id || person))));

	let rows = [];
	results.forEach(e => {
		rows.push({
			"AnonId": getId(e._id),
			"FirstName": e.fname,
			"LastName": e.lname
		});
	});

	const wb = await xlsx.fromBlankAsync();
	const sheet = wb.sheet("Sheet1");
	populateSheet(sheet, DEANON_HEADER, rows, {
		autofit: true
	});

	return wb.toFileAsync(anonName, {
		password: "9MeTeRs!$5523"
	});

}

async function generateAllCSV(db, orgGroup, groupName, rootDir){
	const PROCESSED = {};
	const workflowSchemas = [await getWorkflowSchema(db)];
	const formSchemas = await getFormSchemas(db);
	const formIds = formSchemas.map(e => e._id);

	const patients = await getPatientsIds(db, orgGroup);

	const ongoingWorkflows = await db.collection("assets").find({
		owner: {
			$in: patients
		},
		workflow: WORKFLOW,
		"state.demoMode": false
	}).toArray();

	let workflowResults = [];
	let formResults = [];

	for(const ongoingWorkflow of ongoingWorkflows){
		const owner = ongoingWorkflow.owner;

		const createdAt = new Date(ongoingWorkflow.created_at);
		createdAt.setDate(createdAt.getDate() + DAY_DIFFERENCE);

		const actions = await getActions(db, ongoingWorkflow._id, owner, createdAt);

		workflowResults = workflowResults.concat(actions);

		const formSubmissions = await db.collection("assets").find({
			type: "groupsubmission",
			schema: {
				$in: formIds
			},
			owner: owner,
			$and: [
				{
					created_at: {
						$gte: createdAt
					}
				}, {
					created_at: {
						$lte: END_DATE
					}
				}
			]
		}).toArray();

		if(!PROCESSED[owner.toString()]){
			PROCESSED[owner.toString()] = [formSubmissions];
		} else {
			PROCESSED[owner.toString()] = PROCESSED[owner.toString()].concat(formSubmissions);
		}
	}

	for(const key of Object.keys(PROCESSED)){
		const current = PROCESSED[key];
		let biggest = [];
		for(const arr of current){
			if(arr.length > biggest.length)
				biggest = arr;
		}
		formResults = formResults.concat(biggest);
	}

	const sanitizedName = sanitize(groupName);

	const {headers, rows, headerAccessors} = await FormSpreadsheet.createSingleCsvAllDataRows(workflowSchemas, workflowResults, formSchemas, formResults, path.join(rootDir, `${sanitizedName}-AllData.csv`), {
		delimeter: ",",
		raw: true,
		noCSV: true
	});


	const CSVPath =  path.join(rootDir, `${sanitizedName}-AllData.csv`);
	const XLSXPath = path.join(rootDir, `${sanitizedName}-AllData.xlsx`);

	await createCsv(headers, rows, CSVPath);
	await createMappedCsv(CSVPath, headerAccessors);
	return createXlsx(headers, rows, XLSXPath);
}

function createXlsx(headers, rows, xlsxPath){
	const timestamp = headers.findIndex(e => e === "Sample_Image_Timestamp_Created");

	const weight = timestamp + 1;
	const volume = timestamp + 2;
	const comments = timestamp + 3;
	const uninterpretable = timestamp + 4;
	headers.splice(weight, 0, "Weight (g)");
	headers.splice(volume, 0, "Volume (ml)");
	headers.splice(comments, 0, "Comments (core reviewer)");
	headers.splice(uninterpretable, 0, "Uninterpretable");


	return xlsx.fromBlankAsync().then(wb => {
		var sheet = wb.sheet("Sheet1");
		populateSheet(sheet, headers, rows, {
			autofit: true
		});

		sheet.cell(numToAlpha(weight) + "1").style("fill", "fae9a5");
		sheet.cell(numToAlpha(weight) + "1").style("fontColor", "9c5700");
		sheet.cell(numToAlpha(volume) + "1").style("fill", "fae9a5");
		sheet.cell(numToAlpha(volume) + "1").style("fontColor", "9c5700");
		sheet.cell(numToAlpha(comments) + "1").style("fill", "fae9a5");
		sheet.cell(numToAlpha(comments) + "1").style("fontColor", "9c5700");
		sheet.cell(numToAlpha(uninterpretable) + "1").style("fill", "fae9a5");
		sheet.cell(numToAlpha(uninterpretable) + "1").style("fontColor", "9c5700");

		return wb.toFileAsync(xlsxPath);
	});
}

function createCsv(headers, rows, filePath){
	var csv = toCsv({
		headers: headers,
		seperator: ","
	});

	var writeStream = fs.createWriteStream(filePath);
	csv.pipe(writeStream);
	rows.forEach(row => {
		csv.write(row);
	});
	csv.end();
	return waitClose(writeStream);
}

function createMappedCsv(filePath, headers){
	var writeStreamMap = fs.createWriteStream(filePath.replace(".csv", "_map.csv"));
	var mapCsv = toCsv({
		headers: MAP_CSV,
		seperator: ","
	});

	mapCsv.pipe(writeStreamMap);

	headers.forEach(header => {
		var value_localization = header.value_localization || {};
		var langEn = value_localization.en;

		var enums = header.enums || [];

		var values = langEn ? enums.map(e => `${e} = ${langEn[e]}`).join(", ") : null;

		mapCsv.write({
			Key: header.accessor,
			Localized: header.localized,
			Values: values
		});
	});
	mapCsv.end();
	return waitClose(writeStreamMap);
}

function getPersonData(db, person){
	return db.collection("users").findOne({
		_id: person	
	}, {
		fname: 1,
		lname: 1
	}).then(data => {
		if(!data) return {fname: "N/A", lname: "N/A", _id: person};
		return data;
	})
}

function getWorkflowSchema(db){
	return db.collection("schemas").findOne({
		organization: ORG,
		type: "workflow",
		_id: WORKFLOW
	});
}

function createDirectory(path){
	return mkdirp.sync(path);
}

function getPatients(db, orgGroup){
	return db.collection("users").find({
		orgGroup: orgGroup
	});
}

function getPatientsIds(db, orgGroup){
	return getPatients(db, orgGroup)
		.toArray()
		.then(fjMap(prop("_id")));
}

function getFormSchemas(db){
	return db.collection("schemas").find({
		organization: ORG,
		type: "form"
	}).toArray();
}

function getActions(db, ongoing, owner, created_at){
	return db.collection("assets").aggregate([
		{
			$match: {
				ongoingWorkflow: ongoing,
				responded: true,
				cleared: false,
				owner: owner,
				$and: [
					{created_at: {
						$gte: created_at
					}}, {
						created_at: {
							$lte: END_DATE
						}
					}
				]
			}
		}, {
			$lookup: {
				from: "assets",
				localField: "ongoingWorkflow",
				foreignField: "_id",
				as: "ongoingData"
			}
		},
		{
			$project: {
				_id: 1,
				data: 1,
				action: 1,
				workflow: {$arrayElemAt: ["$ongoingData.workflow", 0]},
				owner: 1,
				updated_at: 1,
				created_at: 1
			}
		}
	]).toArray();
}

function getId(id) {
	return id.toString().slice(0, 4) + id.toString().slice(-4);
}

function waitClose(stream){
	return new Promise((resolve) => {
		stream.on("close", resolve);
	});
}

function getOrgGroups(db, org){
	return db.collection("groups").find({
		organization: org
	}).toArray();
}

function numToAlpha(num) {
	var alpha = '';

	for (; num >= 0; num = (num / 26) - 1) {
		alpha = String.fromCharCode(num % 26 + 0x41) + alpha;
	}

	return alpha;
}

function s3Upload(params){
	let s3 = new AWS.S3();
	return new Promise((resolve, reject) => {
		s3.putObject(params, (err, data) => {
			if(err){
				console.log(err);
				reject(err);
			} else {
				console.log('Successfully uploaded '+ params.Key +' to ' + BUCKET);
				resolve(data);
			}
				
		})
	});
}

function zipDirectory(source, out) {
	const archive = archiver('zip', { zlib: { level: 9 }});
	const stream = fs.createWriteStream(out);

	return new Promise((resolve, reject) => {
		archive
			.directory(source, false)
			.on('error', err => reject(err))
			.pipe(stream);

		stream.on('close', () => resolve(null));
		archive.finalize();
	});
}

function formatFileDate(date){
	var year = date.getFullYear();
	var month = fill(date.getMonth() + 1);
	var day = fill(date.getDate());
	return `${year}${month}${day}`;
}

function fill(number) {
	if (number.toString().length < 2) {
		return "0" + number;
	}
	return number;
}

async function removeDirectory(path) {
	return new Promise((resolve) => {
		rimraf(path, () => {
			resolve(undefined);
		});
	});
}
