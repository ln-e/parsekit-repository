# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 20:05
# To change this template use File | Settings | File Templates.

@CLASS
StaticController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###


@create[]
###


@downloadAction[]
    $data[
        $.dists[^hash::create[]]
    ]

    $files[^file:list[/dists]]

    ^files.menu{
        $match[^files.name.match[^^(\S+)-(\S+)-(\S+)\.tar\.gz^$][gi]]
        ^if($match){
            $data.dists.[^data.dists._count[]][
                $.version[$match.2]
                $.date[^date::unix-timestamp($match.1)]
                $.file[/dists/$files.name]
            ]
        }
    }

    $result[^self.render[$data;../data/templates/static/download.xsl]]
###
