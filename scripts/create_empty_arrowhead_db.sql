DROP DATABASE IF EXISTS `arrowhead`;
CREATE DATABASE IF NOT EXISTS `arrowhead`;
USE `arrowhead`;

-- Common

DROP TABLE IF EXISTS `cloud`;
CREATE TABLE `cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `operator` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `secure` int(1) NOT NULL DEFAULT 0 COMMENT 'Is secure?',
  `neighbor` int(1) NOT NULL DEFAULT 0 COMMENT 'Is neighbor cloud?',
  `own_cloud` int(1) NOT NULL DEFAULT 0 COMMENT 'Is own cloud?',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cloud` (`operator`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `cloud_gatekeeper`;
CREATE TABLE `cloud_gatekeeper` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cloud_id` bigint(20) NOT NULL,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `service_uri` varchar(255) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cloud` (`cloud_id`),
  UNIQUE KEY `address` (`address`, `port`, `service_uri`),
  KEY `fk_cloud` (`cloud_id`),
  CONSTRAINT `fk_cloud` FOREIGN KEY (`cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `system_`;
CREATE TABLE `system_` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `triple` (`system_name`,`address`,`port`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `service_definition`;
CREATE TABLE `service_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_definition` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_definition` (`service_definition`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `service_interface`;
CREATE TABLE `service_interface` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `interface_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `interface` (`interface_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Service Registry

DROP TABLE IF EXISTS `service_registry`;
CREATE TABLE `service_registry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_id` bigint(20) NOT NULL,
  `system_id` bigint(20) NOT NULL,
  `service_uri` varchar(255) DEFAULT NULL,
  `end_of_validity` timestamp NULL DEFAULT NULL,
  `secure` varchar(255) NOT NULL DEFAULT 'NOT_SECURE',
  `metadata` text,
  `version` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`service_id`,`system_id`),
  KEY `system` (`system_id`),
  CONSTRAINT `service` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `system` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `service_registry_interface_connection`;
CREATE TABLE `service_registry_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_registry_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`service_registry_id`,`interface_id`),
  KEY `interface_sr` (`interface_id`),
  CONSTRAINT `interface_sr` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_registry` FOREIGN KEY (`service_registry_id`) REFERENCES `service_registry` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Authorization

DROP TABLE IF EXISTS `authorization_intra_cloud`;
CREATE TABLE `authorization_intra_cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `consumer_system_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `service_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule` (`consumer_system_id`,`provider_system_id`,`service_id`),
  KEY `provider` (`provider_system_id`),
  KEY `service_intra_auth` (`service_id`),
  CONSTRAINT `service_intra_auth` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `provider` FOREIGN KEY (`provider_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `consumer` FOREIGN KEY (`consumer_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `authorization_inter_cloud`;
CREATE TABLE `authorization_inter_cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `consumer_cloud_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `service_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule` (`consumer_cloud_id`, `provider_system_id`, `service_id`),
  KEY `service_inter_auth` (`service_id`),
  CONSTRAINT `cloud` FOREIGN KEY (`consumer_cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_inter_auth` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `provider_inter_auth` FOREIGN KEY (`provider_system_id`) REFERENCES `system_` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `authorization_inter_cloud_interface_connection`;
CREATE TABLE `authorization_inter_cloud_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `authorization_inter_cloud_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`authorization_inter_cloud_id`,`interface_id`),
  KEY `interface_inter` (`interface_id`),
  CONSTRAINT `auth_inter_interface` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `auth_inter_cloud` FOREIGN KEY (`authorization_inter_cloud_id`) REFERENCES `authorization_inter_cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `authorization_intra_cloud_interface_connection`;
CREATE TABLE `authorization_intra_cloud_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `authorization_intra_cloud_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`authorization_intra_cloud_id`,`interface_id`),
  KEY `interface_intra` (`interface_id`),
  CONSTRAINT `auth_intra_interface` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `auth_intra_cloud` FOREIGN KEY (`authorization_intra_cloud_id`) REFERENCES `authorization_intra_cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Relay

DROP TABLE IF EXISTS `relay`;
CREATE TABLE `relay` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `secure` int(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`address`, `port`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Orchestrator

DROP TABLE IF EXISTS `orchestrator_store`;
CREATE TABLE `orchestrator_store` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `consumer_system_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `foreign_` int(1) NOT NULL DEFAULT 0,
  `service_id` bigint(20) NOT NULL,
  `service_interface_id` bigint(20) NOT NULL,
  `priority` int(11) NOT NULL,
  `attribute` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `priority_rule` (`service_id`, `service_interface_id`, `consumer_system_id`,`priority`),
  UNIQUE KEY `duplication_rule` (`service_id`, `service_interface_id`, `consumer_system_id`,`provider_system_id`, `foreign_`),
  CONSTRAINT `consumer_orch` FOREIGN KEY (`consumer_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_orch` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_intf_orch` FOREIGN KEY (`service_interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `foreign_system`;
CREATE TABLE `foreign_system` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `provider_cloud_id` bigint(20) NOT NULL,
  `system_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `triple` (`system_name`,`address`,`port`),
  CONSTRAINT `foreign_cloud` FOREIGN KEY (`provider_cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Logs

DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs` (
  `log_id` varchar(100) NOT NULL,
  `entry_date` timestamp NULL DEFAULT NULL,
  `logger` varchar(100) DEFAULT NULL,
  `log_level` varchar(100) DEFAULT NULL,
  `message` text,
  `exception` text,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Event Handler

DROP TABLE IF EXISTS `event_handler_event`;
CREATE TABLE `event_handler_event` (
  `id` bigint(20) AUTO_INCREMENT PRIMARY KEY,
  `type` varchar(255) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `pair` (`type`, `provider_system_id`),
  CONSTRAINT `event_provider` FOREIGN KEY (`provider_system_id`) REFERENCES `system_` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `event_handler_event_subscriber`;
CREATE TABLE `event_handler_event_subscriber` (
  `id` bigint(20) AUTO_INCREMENT PRIMARY KEY,
  `event_id` bigint(20) NOT NULL,
  `consumer_system_id` bigint(20) NOT NULL,
  `notify_uri` varchar(255) DEFAULT NULL,
  `filter_metadata` text,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `event_consumer` FOREIGN KEY (`consumer_system_id`) REFERENCES `system_` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Choreographer

DROP TABLE IF EXISTS `choreographer_action_plan`;
CREATE TABLE `choreographer_action_plan` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT NOW(),
  `updated_at` timestamp NOT NULL DEFAULT NOW() ON UPDATE NOW()
)ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_action`;
CREATE TABLE `choreographer_action` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `next_action_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT NOW(),
  `updated_at` timestamp NOT NULL DEFAULT NOW() ON UPDATE NOW(),
  -- CONSTRAINT `action_plan` FOREIGN KEY (`action_plan_id`) REFERENCES `action_plan`(`id`),
  CONSTRAINT `next_action` FOREIGN KEY (`next_action_id`) REFERENCES `choreographer_action` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_action_step`;
CREATE TABLE `choreographer_action_step` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  -- `action_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT NOW(),
  `updated_at` timestamp NOT NULL DEFAULT NOW() ON UPDATE NOW()
  -- CONSTRAINT `action` FOREIGN KEY (`action_id`) REFERENCES `action`(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_action_plan_action_connection`;
CREATE TABLE `choreographer_action_plan_action_connection` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `action_plan_id` bigint(20) NOT NULL,
  `action_id` bigint(20) NOT NULL,
  CONSTRAINT `action_plan_fk1` FOREIGN KEY (`action_plan_id`) REFERENCES `choreographer_action_plan` (`id`),
  CONSTRAINT `action_fk1` FOREIGN KEY (`action_id`) REFERENCES `choreographer_action` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_action_action_step_connection`;
CREATE TABLE `choreographer_action_action_step_connection` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `action_id` bigint(20) NOT NULL,
  `action_step_id` bigint(20) NOT NULL,
  CONSTRAINT `action_fk2` FOREIGN KEY (`action_id`) REFERENCES `choreographer_action` (`id`),
  CONSTRAINT `action_step_fk1` FOREIGN KEY (`action_step_id`) REFERENCES `choreographer_action_step` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_action_step_service_definition_connection`;
CREATE TABLE `choreographer_action_step_service_definition_connection` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `action_step_id` bigint(20) NOT NULL,
  `service_definition_id` bigint(20) NOT NULL,
  CONSTRAINT `service_definition` FOREIGN KEY (`service_definition_id`) REFERENCES `service_definition` (`id`),
  CONSTRAINT `action_step` FOREIGN KEY (`action_step_id`) REFERENCES `choreographer_action_step` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `choreographer_next_action_step`;
CREATE TABLE `choreographer_next_action_step` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `action_step_id` bigint(20) NOT NULL,
  `next_action_step_id` bigint(20) NOT NULL,
  CONSTRAINT `current_action_step` FOREIGN KEY (`action_step_id`) REFERENCES `choreographer_action_step` (`id`),
  CONSTRAINT `next_action_step` FOREIGN KEY (`action_step_id`) REFERENCES `choreographer_action_step` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Set up privileges

-- Service Registry
DROP USER IF EXISTS 'service_registry'@'localhost';
CREATE USER IF NOT EXISTS 'service_registry'@'localhost' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'service_registry'@'localhost';

DROP USER IF EXISTS 'service_registry'@'%';
CREATE USER IF NOT EXISTS 'service_registry'@'%' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'service_registry'@'%';

-- Authorization
DROP USER IF EXISTS 'authorization'@'localhost';
CREATE USER IF NOT EXISTS 'authorization'@'localhost' IDENTIFIED BY 'hqZFUkuHxhekio3';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'authorization'@'localhost';

DROP USER IF EXISTS 'authorization'@'%';
CREATE USER IF NOT EXISTS 'authorization'@'%' IDENTIFIED BY 'hqZFUkuHxhekio3';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'authorization'@'%';

-- Orchestrator
DROP USER IF EXISTS 'orchestrator'@'localhost';
CREATE USER IF NOT EXISTS 'orchestrator'@'localhost' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'localhost';

DROP USER IF EXISTS 'orchestrator'@'%';
CREATE USER IF NOT EXISTS 'orchestrator'@'%' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'%';

-- Event Handler
DROP USER IF EXISTS 'event_handler'@'localhost';
CREATE USER IF NOT EXISTS 'event_handler'@'localhost' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
GRANT ALL PRIVILEGES ON `arrowhead`.`event_handler_event` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`event_handler_event_subscriber` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'event_handler'@'localhost';

DROP USER IF EXISTS 'event_handler'@'%';
CREATE USER IF NOT EXISTS 'event_handler'@'%' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
GRANT ALL PRIVILEGES ON `arrowhead`.`event_handler_event` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`event_handler_event_subscriber` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'event_handler'@'%';

-- Choreographer
DROP USER IF EXISTS 'choreographer'@'localhost';
CREATE USER IF NOT EXISTS 'choreographer'@'localhost' IDENTIFIED BY 'Qa5yx4oBp4Y9RLX';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan_action_connection` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_action_step_connection` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step_service_definition_connection` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_next_action_step` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'choreographer'@'localhost';

DROP USER IF EXISTS 'choreographer'@'%';
CREATE USER IF NOT EXISTS 'choreographer'@'%' IDENTIFIED BY 'Qa5yx4oBp4Y9RLX';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan_action_connection` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_action_step_connection` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step_service_definition_connection` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_next_action_step` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'choreographer'@'%';

-- Gatekeeper
DROP USER IF EXISTS 'gatekeeper'@'localhost';
CREATE USER IF NOT EXISTS 'gatekeeper'@'localhost' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gatekeeper'@'localhost';

DROP USER IF EXISTS 'gatekeeper'@'%';
CREATE USER IF NOT EXISTS 'gatekeeper'@'%' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gatekeeper'@'%';

-- Gateway
DROP USER IF EXISTS 'gateway'@'localhost';
CREATE USER IF NOT EXISTS 'gateway'@'localhost' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gateway'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'gateway'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gateway'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gateway'@'localhost';

DROP USER IF EXISTS 'gateway'@'%';
CREATE USER IF NOT EXISTS 'gateway'@'%' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gateway'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper` TO 'gateway'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gateway'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gateway'@'%';

FLUSH PRIVILEGES;
