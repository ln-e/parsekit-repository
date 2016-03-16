# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 01.05.16
# Time: 11:25
# To change this template use File | Settings | File Templates.

@CLASS
Utils

@OPTIONS
locals

@auto[]
###

@create[]
###

@handleData[data]
    ^curl:options[$.library[/usr/lib/libcurl.dylib]]


    $packageName[$data.repository.full_name]


    ^if(-f '/p/${packageName}.json' ){
        $oldFileData[^self.parseJson[/p/${packageName}.json](true)]
    }

    $fileData[
        $.packages[
            $.$packageName[^hash::create[]]
        ]
    ]


    $refs[^self.parseJson[^self.sanitizeUrl[$data.repository.git_refs_url]]]

    ^refs.foreach[k;ref]{
        $name[^ref.ref.match[(refs\/(?:heads|tags)\/)][gi]{}]
        $sha[$ref.object.sha]
        ^if(
            ^fileData.packages.[$packageName].contains[$name] &&
            $fileData.packages.[$packageName].$name.source.reference eq $sha
        ){
        Просто копипаста
            $fileData.packages.[$packageName].$name[$oldFileData.packages.[$packageName].$name]
        }{

            $parsekitConfig[^self.getParkitFile[$data;$sha]]
            $parsekitConfig.uid(1)
            $parsekitConfig.version[^if(^ref.ref.pos[refs/tags/master] != -1){dev-master}{$name}]
            $parsekitConfig.source[
                $.type[git]
                $.url[$data.repository.clone_url]
                $.reference[$hash]
            ]
            $parsekitConfig.dist[
                $.type[zip]
                $.url[https://api.github.com/repos/ln-e/debug/zipball/$hash]
                $.reference[$hash]
                $.shasum[]
            ]
            $fileData.packages.[$packageName].$name[$parsekitConfig]
        }
    }

    $string[^json:string[$fileData;$.indent(true)]]

    ^string.save[/p/${packageName}.json]

    $result[${packageName}.json saved]


@createPackage[][result]
    $package[^hash::create[]]
    $result[$package]



@sanitizeUrl[url;params][result]
    ^if($params is hash){
        ^params.foreach[key;value]{
            $url[^url.replace[{$key};$value]]
        }
    }
    $result[^url.match[({\D+})][gi]{}]
    $result[^taint[as-is][$result]]



@getParkitFile[data;sha][result]
    $file[^self.parseJson[^self.sanitizeUrl[$data.repository.trees_url;$.[/sha][/$sha]]]]
    $url[]
    ^file.tree.foreach[i;config]{
        ^if($config.path eq 'parsekit.json'){
            $url[$config.url]
        }
    }
    $result[]
    ^if(def $url){

        $parserkitFile[^self.parseJson[$url]]
        $result[^json:parse[
            ^taint[as-is][^string:base64[^parserkitFile.content.mid(0;^parserkitFile.content.length[]-1)]]
        ]]
    }
###


@parseJson[url;local][result]
    $file[^self.load[$url]($local)]
    $result[^json:parse[^taint[as-is][$file.text]]]


@load[url;local][result]
    ^if($local){
        $result[^file::load[text;$url]]
    }{
        $result[^curl:load[
            $.url[^taint[as-is][$url]]
            $.useragent[parsekit]
            $.timeout(20)
            $.ssl_verifypeer(0)
        ]]
    }


