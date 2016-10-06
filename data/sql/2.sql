ALTER TABLE `package` ADD COLUMN repository_url VARCHAR(255), ADD COLUMN repository_name VARCHAR(255);
UPDATE `package` SET repository_url = CONCAT('https://github.com/', package.name), repository_name = package.name;
ALTER TABLE `package` ADD UNIQUE (repository_url);
ALTER TABLE `package` ADD UNIQUE (repository_name);
