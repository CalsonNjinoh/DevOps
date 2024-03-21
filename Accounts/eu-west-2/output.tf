output "vpc_id" {
  description = "VPC ID"
 value       = module.network.vpc_id
}

output "vasco_redis_instance_id" {
  value = module.vasco_redis.instance_id
}

output "tupacase_instance_id" {
  value = module.tupacase.instance_id
}

output "green_postgress_logs_instance_id" {
  value = module.green_posgress-logs.instance_id
}

output "glaretram_mqtt_instance_id" {
  value = module.Glaretram_MQTT.instance_id
}

output "glaretram_instance_id" {
  value = module.glaretram.instance_id
}

output "bobones_mongo_replica_instance_id" {
  value = module.bobones_mongo-replica.instance_id
}

output "mongo_arbiter_instance_id" {
  value = module.mongo_arbiter.instance_id
}

output "valize_mongo_replica_instance_id" {
  value = module.valize_mongo_replica.instance_id
}
