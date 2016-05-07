CREATE TABLE `author` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255),
  `homepage` VARCHAR(255)
);

CREATE TABLE `package` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
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
  `package` INTEGER NOT NULL,
  `user` INTEGER NOT NULL
);
ALTER TABLE `package_user` ADD UNIQUE `unique_index`(`user`, `package`);

CREATE INDEX `idx_package_user` ON `package_user` (`user`);

ALTER TABLE `package_user` ADD CONSTRAINT `fk_package_user__package` FOREIGN KEY (`package`) REFERENCES `package` (`id`);

ALTER TABLE `package_user` ADD CONSTRAINT `fk_package_user__user` FOREIGN KEY (`user`) REFERENCES `user` (`id`);

CREATE TABLE `version` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `package` INTEGER NOT NULL,
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

CREATE INDEX `idx_version__package` ON `version` (`package`);

ALTER TABLE `version` ADD CONSTRAINT `fk_version__package` FOREIGN KEY (`package`) REFERENCES `package` (`id`);

CREATE TABLE `author_version` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `author` INTEGER NOT NULL,
  `version` INTEGER NOT NULL
);
ALTER TABLE `author_version` ADD UNIQUE `unique_index`(`author`, `version`);

CREATE INDEX `idx_author_version` ON `author_version` (`version`);

ALTER TABLE `author_version` ADD CONSTRAINT `fk_author_version__author` FOREIGN KEY (`author`) REFERENCES `author` (`id`);

ALTER TABLE `author_version` ADD CONSTRAINT `fk_author_version__version` FOREIGN KEY (`version`) REFERENCES `version` (`id`);

CREATE TABLE `dev_requires_relation` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `version` INTEGER NOT NULL,
  `requirements` VARCHAR(255) NOT NULL,
  `package` INTEGER NOT NULL
);

CREATE INDEX `idx_dev_requires_relation__package` ON `dev_requires_relation` (`package`);

CREATE INDEX `idx_dev_requires_relation__version` ON `dev_requires_relation` (`version`);

ALTER TABLE `dev_requires_relation` ADD CONSTRAINT `fk_dev_requires_relation__package` FOREIGN KEY (`package`) REFERENCES `package` (`id`);

ALTER TABLE `dev_requires_relation` ADD CONSTRAINT `fk_dev_requires_relation__version` FOREIGN KEY (`version`) REFERENCES `version` (`id`);

CREATE TABLE `requires_relation` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `version` INTEGER NOT NULL,
  `requirements` VARCHAR(255) NOT NULL,
  `package` INTEGER NOT NULL
);

CREATE INDEX `idx_requires_relation__package` ON `requires_relation` (`package`);

CREATE INDEX `idx_requires_relation__version` ON `requires_relation` (`version`);

ALTER TABLE `requires_relation` ADD CONSTRAINT `fk_requires_relation__package` FOREIGN KEY (`package`) REFERENCES `package` (`id`);

ALTER TABLE `requires_relation` ADD CONSTRAINT `fk_requires_relation__version` FOREIGN KEY (`version`) REFERENCES `version` (`id`)
