# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 20:36
# To change this template use File | Settings | File Templates.

@CLASS
BaseController

@OPTIONS
locals

@auto[]
###

@create[]
###


@redirect[url]
    $response:refresh[
       $.value(0)
       $.url[$url]
    ]
    $result[]
###


@parseJson[url;local][result]
    $file[^self.load[$url]($local)]
    $result[^json:parse[^taint[as-is][$file.text]]]
###



@load[url;local][result]
    ^if(def $local && $local){
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
