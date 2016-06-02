# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 12:19
# To change this template use File | Settings | File Templates.

@CLASS
StatController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###


@create[]
###


@downloadsAction[packageName][result]
    ^connect[$MAIN:SQL.connect-string]{
        $r[^void:sql{
            UPDATE
              package
            SET
              package.installs = package.installs + 1
            WHERE
              package.name = '$packageName'
        }]
    }
    $result[{"result": "ok"}]
###
