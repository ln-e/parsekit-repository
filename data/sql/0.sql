CREATE TABLE `author` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255),
  `homepage` VARCHAR(255)
);

CREATE TABLE `package` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `hook_id` INTEGER,
  `name` VARCHAR(255) UNIQUE NOT NULL,
  `target_dir` VARCHAR(255) UNIQUE NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `keywords` 	LONGTEXT NOT NULL,
  `readme` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `indexed_at` TIMESTAMP
);

CREATE TABLE `user` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `github_id` VARCHAR(255),
  `github_token` VARCHAR(255)
);

CREATE TABLE `package_user` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `package_id` INTEGER NOT NULL,
  `user_id` INTEGER NOT NULL
);
ALTER TABLE `package_user` ADD UNIQUE `unique_index`(`user_id`, `package_id`);

CREATE INDEX `idx_package_user` ON `package_user` (`user_id`);

ALTER TABLE `package_user` ADD CONSTRAINT `fk_package_user__package` FOREIGN KEY (`package_id`) REFERENCES `package` (`id`) ON DELETE CASCADE;

ALTER TABLE `package_user` ADD CONSTRAINT `fk_package_user__user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

CREATE TABLE `version` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `package_id` INTEGER NOT NULL,
  `version` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `homepage` VARCHAR(255),
  `class_path` LONGTEXT,
  `source_url` LONGTEXT,
  `source_type` VARCHAR(255),
  `source_reference` VARCHAR(255),
  `dist_url` LONGTEXT,
  `dist_type` VARCHAR(255),
  `dist_reference` VARCHAR(255),
  `released_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parsekit_json` LONGTEXT NOT NULL
);

CREATE INDEX `idx_version__package` ON `version` (`package_id`);

ALTER TABLE `version` ADD CONSTRAINT `fk_version__package` FOREIGN KEY (`package_id`) REFERENCES `package` (`id`) ON DELETE CASCADE;

CREATE TABLE `author_version` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `author_id` INTEGER NOT NULL,
  `version_id` INTEGER NOT NULL
);
ALTER TABLE `author_version` ADD UNIQUE `unique_index`(`author_id`, `version_id`);

CREATE INDEX `idx_author_version` ON `author_version` (`version_id`);

ALTER TABLE `author_version` ADD CONSTRAINT `fk_author_version__author` FOREIGN KEY (`author_id`) REFERENCES `author` (`id`) ON DELETE CASCADE;

ALTER TABLE `author_version` ADD CONSTRAINT `fk_author_version__version` FOREIGN KEY (`version_id`) REFERENCES `version` (`id`) ON DELETE CASCADE;

CREATE TABLE `dev_requires_relation` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `version_id` INTEGER NOT NULL,
  `requirements` VARCHAR(255) NOT NULL,
  `package_id` INTEGER NOT NULL
);

CREATE INDEX `idx_dev_requires_relation__package` ON `dev_requires_relation` (`package_id`);

CREATE INDEX `idx_dev_requires_relation__version` ON `dev_requires_relation` (`version_id`);

ALTER TABLE `dev_requires_relation` ADD CONSTRAINT `fk_dev_requires_relation__package` FOREIGN KEY (`package_id`) REFERENCES `package` (`id`) ON DELETE CASCADE;

ALTER TABLE `dev_requires_relation` ADD CONSTRAINT `fk_dev_requires_relation__version` FOREIGN KEY (`version_id`) REFERENCES `version` (`id`) ON DELETE CASCADE;

CREATE TABLE `requires_relation` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `version_id` INTEGER NOT NULL,
  `requirements` VARCHAR(255) NOT NULL,
  `package_id` INTEGER NOT NULL
);

CREATE INDEX `idx_requires_relation__package` ON `requires_relation` (`package_id`);

CREATE INDEX `idx_requires_relation__version` ON `requires_relation` (`version_id`);

ALTER TABLE `requires_relation` ADD CONSTRAINT `fk_requires_relation__package` FOREIGN KEY (`package_id`) REFERENCES `package` (`id`) ON DELETE CASCADE;

ALTER TABLE `requires_relation` ADD CONSTRAINT `fk_requires_relation__version` FOREIGN KEY (`version_id`) REFERENCES `version` (`id`) ON DELETE CASCADE
