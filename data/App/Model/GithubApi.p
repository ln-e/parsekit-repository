# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 09.05.16
# Time: 12:28
# To change this template use File | Settings | File Templates.

@CLASS
GithubApi

@OPTIONS
locals

@auto[]
    $self.clientId[$MAIN:GithubClientId]
    $self.secret[$MAIN:GithubSecret]
###


@create[security]
    $self.security[$security]
    $user[^self.security.getUser[]]
    $self.access_token[$user.github_token]
    $self.parsekitFileCache[^hash::create[]]
###



@getParsekitFile[repoName;sha][result]
    $key[${repoName}$sha]
    ^if(!^self.parsekitFileCache.contains[$key]){
        $file[^self.getSourceFile[$repoName;$sha;parsekit.json]]
        $self.parsekitFileCache.$key[^self.decodeFile[$file]]
    }
    $result[$self.parsekitFileCache.$key]
###


@getSourceFile[repoName;sha;fileName][result]
    $file[^self.makeRequest[https://raw.githubusercontent.com/$repoName/$sha/$fileName;](false)]
    $result[$file]
###


@getAccessToken[code][result]
    $data[client_id=$self.clientId&client_secret=$self.secret&code=$code]
    $file[^self.makeRequest[https://github.com/login/oauth/access_token;$data](false)]
    $result[^self.decodeFile[$file]]
###


@getUser[][result]
    $file[^self.makeRequest[https://api.github.com/user;](true)]
    $result[^self.decodeFile[$file]]
###


@createRepoHook[packageName][result]
    $data[{
        "name": "web",
        "active": true,
        "events": ["create","delete","push","release"],
        "config": {"url": "http://parsekit.ru/hook","content_type": "json"}
    }]

    $file[^self.makeRequest[https://api.github.com/repos/$packageName/hooks;$data](true)]
    $result[^self.decodeFile[$file]]
###


@ping[packageName;id][result]
    $result[]
    $file[^self.makeRequest[https://api.github.com/repos/$packageName/hooks/$id/pings; ](true)]
###


@makeRequest[url;postData;auth][result]
    $result[^curl:load[
        $.url[$url]
        $.useragent[parsekit]
        $.timeout(10)
        $.ssl_verifypeer(0)
        $.httpheader[
            $.accept[application/json]
            ^if($auth){
                $.Authorization[token $self.access_token]
            }
        ]
        ^if(def $postData){
            $.post(1)
            $.postfields[$postData]
        }
    ]]
###


@decodeFile[file][result]
    $result[^json:parse[^taint[as-is][$file.text]]]
###
