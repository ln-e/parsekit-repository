# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 01.05.16
# Time: 11:25
# To change this template use File | Settings | File Templates.

@CLASS
HookController

@OPTIONS
locals

@auto[]
###

@create[]
###


@hookAction[debugData]
    $data[^json:parse[^taint[as-is][^if(def $debugData){$debugData}{$request:body}]]]

    $packageName[$data.repository.full_name]
    $ref[$data.ref]
    $name[^ref.ref.match[(refs\/(?:heads|tags)\/)][gi]{}]
    $sha[$ref.object.sha]

    ^if(-f '/p/${packageName}.json' ){
        $fileData[^self.parseJson[/p/${packageName}.json](true)]
    }{
        $fileData[
            $.packages[
                $.$packageName[^hash::create[]]
            ]
        ]
    }

    ^if(
        !^fileData.packages.[$packageName].contains[$name] ||
        $fileData.packages.[$packageName].$name.source.reference ne $sha
    ){
        $fileData.packages.[$packageName].$name[^self.createPackageConfig[$data;$packageName;$sha;$ref;$name]]
    }

    $string[^json:string[$fileData;$.indent(true)]]
    ^string.save[/p/${packageName}.json]

    $result[${packageName}.json saved]
###


@createPackageAction[debugData]
    $data[^json:parse[^taint[as-is][^if(def $debugData){$debugData}{$request:body}]]]
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
#           if not changed ref then do not update
            $fileData.packages.[$packageName].$name[$oldFileData.packages.[$packageName].$name]
        }{
            $fileData.packages.[$packageName].$name[^self.createPackageConfig[$data;$packageName;$sha;$ref;$name]]
        }
    }

    $string[^json:string[$fileData;$.indent(true)]]

    ^string.save[/p/${packageName}.json]

    $result[${packageName}.json saved]
###


@createPackageConfig[data;packageName;sha;ref;name][result]
    $parsekitConfig[^self.getParkitFile[$packageName;$sha]]
    $parsekitConfig.name[$packageName]
    $parsekitConfig.targetDir[$packageName]
    $parsekitConfig.uid(1)
    $parsekitConfig.version[^if(^ref.ref.pos[refs/heads/master] != -1){dev-master}{$name}]
    $parsekitConfig.source[
        $.type[git]
        $.url[$data.repository.clone_url]
        $.reference[$sha]
    ]
    $parsekitConfig.dist[
        $.type[zip]
        $.url[https://api.github.com/repos/$packageName/zipball/$sha]
        $.reference[$sha]
    ]

    $result[$parsekitConfig]
###


@sanitizeUrl[url;params][result]
    ^if($params is hash){
        ^params.foreach[key;value]{
            $url[^url.replace[{$key};$value]]
        }
    }
    $result[^url.match[({\D+})][gi]{}]
    $result[^taint[as-is][$result]]
###


@getParkitFile[name;sha][result]
    $result[^self.parseJson[https://raw.githubusercontent.com/$name/$sha/parsekit.json]]
###


@parseJson[url;local][result]
    $file[^self.load[$url]($local)]
    $result[^json:parse[^taint[as-is][$file.text]]]
###


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
###
