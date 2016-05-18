# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 01.05.16
# Time: 11:25
# To change this template use File | Settings | File Templates.

@CLASS
HookController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###

@create[]
    $self.githubApi[$DI:githubApi]
    $self.packageManager[$DI:packageManager]
###


@chooseByTypeAction[]
    $type[$request:headers.[X_GITHUB_EVENT]]
    ^switch[$type]{
        ^case[push]{^self.pushAction[]}
        ^case[delete]{^self.deleteAction[]}
        ^case[create]{^self.createAction[]}
        ^case[release]{^self.releaseAction[]}
        ^case[ping]{^self.checkAllPackageVersionAction[]}
        ^case[DEFAULT]{^throw[ActionNotImplementedException;;Unknown hook type $type]}
    }
###


@pushAction[][result]
    $data[^json:parse[^taint[as-is][$request:body]]]

    $packageName[$data.repository.full_name]
    $sha[$data.after]
    $version[^data.ref.match[(refs\/(?:heads|tags)\/)][gi]{}]

    ^connect[$MAIN:SQL.connect-string]{
        $package[^table::sql{
            SELECT * FROM package WHERE package.name = '$packageName'
        }[$.limit(1)]]


        ^if(!($package is table && def $package)){
            ^throw[UnregistredHookException;;Package '$packageName' was not registred in parsekit repostiory.]
        }
    }

    ^self.packageManager.addVersion[$data;$package.fields;$sha;$version]
    $result[${package.target_dir}.json saved]
###


@createAction[][result]
    $data[^json:parse[^taint[as-is][$request:body]]]

    $packageName[$data.repository.full_name]
    $version[$data.ref]

    ^connect[$MAIN:SQL.connect-string]{
        $package[^table::sql{
            SELECT * FROM package WHERE package.name = '$packageName'
        }[$.limit(1)]]


        ^if(!($package is table && def $package)){
            ^throw[UnregistredHookException;;Package '$packageName' was not registred in parsekit repostiory.]
        }
    }

    ^if($data.ref_type eq tag){
        $url[^self.sanitizeUrl[$data.repository.git_refs_url;$.sha[/tags/$data.ref]]]
    }($data.ref_type eq branch){
        $url[^self.sanitizeUrl[$data.repository.git_refs_url;$.sha[/heads/$data.ref]]]
    }{
        ^throw[InvalidRequestException;;Unsupported ref type $data.ref_type]
    }

    $refs[^self.githubApi.decodeFile[^self.githubApi.makeRequest[$url]]]
    $sha[$refs.object.sha]

    ^self.packageManager.addVersion[$data;$package;$sha;$version]
    $result[${package.target_dir}.json saved]
###


@releaseAction[][result]
    $data[^json:parse[^taint[as-is][$request:body]]]

    $packageName[$data.repository.full_name]
    $version[$data.release.tag_name]

    ^connect[$MAIN:SQL.connect-string]{
        $package[^table::sql{
            SELECT * FROM package WHERE package.name = '$packageName'
        }[$.limit(1)]]

        $package[$package.fields]

        ^if(!($package is hash && def $package)){
            ^throw[UnregistredHookException;;Package '$packageName' was not registred in parsekit repostiory.]
        }
    }

    $url[^self.sanitizeUrl[$data.repository.git_refs_url;$.sha[/tags/$data.release.tag_name]]]
    $refs[^self.githubApi.decodeFile[^self.githubApi.makeRequest[$url]]]
    $sha[$refs.object.sha]

    ^self.packageManager.addVersion[$data;$package;$sha;$version]
    $result[${package.target_dir}.json saved]
###


@deleteAction[]
    $data[^json:parse[^taint[as-is][$request:body]]]
    $packageName[$data.repository.full_name]

    ^connect[$MAIN:SQL.connect-string]{
        $package[^table::sql{
            SELECT * FROM package WHERE package.name = '$packageName'
        }[$.limit(1)]]


        ^if(!($package is table && def $package)){
            ^throw[UnregistredHookException;;Package '$packageName' was not registred in parsekit repostiory.]
        }
    }

    ^self.packageManager.removeVersion[$package;$data.ref]
    $result[${package.target_dir}.json saved]
###


@checkAllPackageVersionAction[]
    $data[^json:parse[^taint[as-is][$request:body]]]
    $packageName[$data.repository.full_name]

    ^connect[$MAIN:SQL.connect-string]{
        $package[^table::sql{
            SELECT * FROM package WHERE package.name = '$packageName'
        }[$.limit(1)]]


        ^if(!($package is table && def $package)){
            ^throw[UnregistredHookException;;Package "$packageName" was not registred in parsekit repostiory.]
        }
    }

    $refs[^self.parseJson[^self.sanitizeUrl[$data.repository.git_refs_url]]]
    ^self.packageManager.addVersions[$data;$package;$refs]
    $result[${package.target_dir}.json saved]
###


@sanitizeUrl[url;params][result]
    ^if($params is hash){
        ^params.foreach[key;value]{
            $url[^url.replace[{/$key};$value]]
        }
    }
    $result[^url.match[({\D+})][gi]{}]
    $result[^taint[as-is][$result]]
###
