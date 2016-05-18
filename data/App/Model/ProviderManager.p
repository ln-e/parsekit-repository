# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 17.05.16
# Time: 19:31
# To change this template use File | Settings | File Templates.

@CLASS
ProviderManager

@OPTIONS
locals


@auto[]
###


@create[]
###


@dumpMainConfig[][result]
    $result[]
    $packages[
        $.protocol(1)
        $.packages[^hash::create[]]
        $.notify[/downloads/%packages%]
        $.search[/search.json?q=%query%]
        $.packageUrl[/p/%package%.json]
        $.providers[^hash::create[]]
    ]

    ^connect[$MAIN:SQL.connect-string]{
        $providers[^table::sql{
            SELECT DATE_FORMAT(package.created_at, '%Y-%m') as provider, count(package.id) as count
            FROM package
            GROUP BY provider
        }]
        ^providers.menu{
            $dumpedData[^self.doDumpProvider[$providers.provider]]
            $packages.providers.[$dumpedData.pattern][
                $.hash[$dumpedData.hash]
            ]
        }
    }

    $string[^json:string[$packages;$.indent(true)]]
    ^string.save[/packages.json]
###


@dumpProvider[providerKey][result]
    $result[^self.doDumpProvider[$providerKey]]
    $file[^file::load[text;/packages.json]]
    $packages[^json:parse[^taint[as-is][$file.text]]]

    $packages.providers.[$result.pattern][
        $.hash[$result.hash]
    ]

    $string[^json:string[$packages;$.indent(true)]]
    ^string.save[/packages.json]
###


@doDumpProvider[providerKey][result]
    $providerData[
        $.providers[^hash::create[]]
    ]
    $path[/p/${providerKey}.json]

    ^connect[$MAIN:SQL.connect-string]{
        $packages[^table::sql{
            SELECT package.id, package.name
            FROM package
            WHERE DATE_FORMAT(package.created_at, '%Y-%m') = '$providerKey'
        }]
        $indexedId[^hash::create[]]
        ^packages.menu{
            $providerData.providers.[$packages.name][
                $.hash[] ^rem{todo get real hash of /p/${packages.name}.json file}
            ]
            $indexedId.[$packages.id][]
        }

        $string[^json:string[$providerData;$.indent(true)]]
        ^string.save[$path]
        $hash[^math:md5[$string]]

        $r[^void:sql{
            UPDATE package SET indexed_at = CURRENT_TIMESTAMP()
            WHERE package.id IN (^indexedId.foreach[id;v]{$id}[,])
        }]
    }

    $result[
        $.pattern[$path]
        $.hash[$hash]
    ]
###


@providerKeyByPackage[package][result]
    ^if(!($package is hash) && !($package is table)){
        $packageId[$package.id]
    }{
        $packageId[$package]
    }
    ^connect[$MAIN:SQL.connect-string]{
        $result[^string:sql{SELECT DATE_FORMAT(package.created_at, '%Y-%m') as providerKey FROM package WHERE package.id = $packageId}[$.limit(1)]]
    }
###
