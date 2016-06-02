# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 01.05.16
# Time: 11:25
# To change this template use File | Settings | File Templates.

@CLASS
MigrationController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###

@create[]
###


@migrateAction[]
    $result[]
    ^connect[$MAIN:SQL.connect-string]{

        ^void:sql{
            CREATE TABLE IF NOT EXISTS `migrations` (
                `version` VARCHAR(255) UNIQUE NOT NULL
            )
        }

        $versions[^hash::sql{
            SELECT version FROM migrations ORDER BY version
        }]
        $missingVersions[^table::create{version}]

        $files[^file:list[/../data/sql;.*\.sql]]
        ^files.menu{
            ^if(!^versions.contains[^file:justname[$files.name]]){
                ^missingVersions.append[^file:justname[$files.name]]
            }
        }
        ^missingVersions.sort{$missingVersions.version}

        $result[^if(^missingVersions.count[] == 0){No migrations to execute}{Executed:}]
        ^missingVersions.menu{
            $file[^file::load[text;/../data/sql/${missingVersions.version}.sql]]
            $queries[^file.text.split[^;]]
            ^queries.menu{
                $sql[^queries.piece.trim[both]]
                ^if(def $sql && $sql ne ''){
                    ^void:sql{^taint[as-is][$sql]}
                }
            }
            ^void:sql{INSERT INTO migrations values($missingVersions.version)}
            $result[$result ${missingVersions.version}.sql,]
        }
    }
###
