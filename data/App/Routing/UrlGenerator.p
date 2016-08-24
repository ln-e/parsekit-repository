# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 12.05.16
# Time: 0:24
# To change this template use File | Settings | File Templates.

@CLASS
UrlGenerator

@OPTIONS
locals

@auto[]
#   i.e. http://domain.ru/dir/file
    $self.ABSOLUTE_URL(0)
#   i.e. /dir/file
    $self.ABSOLUTE_PATH(1)
#   i.e. ../parent-file
    $self.RELATIVE_PATH(2)
#   i.e. //example.com/dir/file
    $self.NETWORK_PATH(3)
###


@create[routes]
    $self.routes[$routes]
    $self.strictRequirements(true)
###


@generate[name;parameters;referenceType][result]
    ^if(!def $referenceType){
        $referenceType[$self.ABSOLUTE_PATH]
    }
    $route[$self.routes.$name]
    ^if(!def $route){
        ^throw[RouteNotFoundException;;Unable to generate a URL for the named route "$name" as such route does not exist.]
    }

    $compiledRoute[^route.compile[]]
    $result[^self.doGenerate[$compiledRoute.variables;$route.defaults;$route.requirements;$compiledRoute.tokens;$parameters;$name;$referenceType;$compiledRoute.hostTokens;$route.schemes]]
###


@doGenerate[variables;defaults;requirements;tokens;parameters;name;referenceType;hostTokens;requiredSchemes]
    ^if(!($requiredSchemes is hash)){ $requiredSchemes[^hash::create[]]}
    $mergedParams[^parameters.union[$defaults]]
    $variables[^variables.foreach[key;value]{$.$value[$key]}] ^rem[ flip variables]
    $diff[^hash::create[$variables]]
    ^diff.sub[$mergedParams]
    ^if(^diff._count[] > 0){
        ^throw[MissingMandatoryParametersException;;Some mandatory parameters are missing ("^diff.foreach[key;value]{$key}[, ]") to generate a URL for route "$name"]
    }

    $url[]
    $optional(true)
    ^tokens.foreach[ind;token]{
        ^if('variable' eq $token.0){
            ^if(
                !$optional
                || !^defaults.contains[$token.3]
                || !def $mergedParams.[$token.3]
                && $mergedParams.[$token.3] eq $defaults.[$token.3]
            ){
                ^if(def $self.strictRequirements && ^mergedParams.[$token.3].match[^^$token.2^$][in] <=0){
                    ^if($self.strictRequirements){
                        ^throw[InvalidParameterException;;^self.generateErrorMessage[$token.3;$name;$token.2;$mergedParams.[$token.3]]]
                    }
                    ^continue[]
                }
                $url[${token.1}${mergedParams.[$token.3]}$url]
                $optional(false)
            }
        }{
#           static text
            $url[${token.1}$url]
            $optional(false)
        }
    }

    ^if('' eq $url){
        $url[/]
    }

    $schemeAuthority[]
    $host[$env:fields.SERVER_NAME]
    ^if(def $host){
#       TODO MOVE scheme and host to routecontext
        $scheme[^if(def $env:HTTPS){https}{http}]
        ^if($requiredSchemes is hash && def $requiredSchemes){
            if (!^requiredSchemes.contains[$scheme]) {
                $referenceType[$self.ABSOLUTE_URL]
                $scheme[^requiredSchemes._at[first]]
            }
        }
        ^if(def $hostTokens && $hostTokens is hash){
            $routeHost[]
            ^hostTokens.foreach[k;token]{
                ^if(variable eq $token.0) {
                    ^if(def $self.strictRequirements && ^mergedParams.[$token.3].match[^^$token.2^$][in] <=0){
                        ^if($self.strictRequirements){
                            ^throw[InvalidParameterException;;^self.generateErrorMessage[$token.3;$name;$token.2;$mergedParams.[$token.3]]]
                        }
                        ^continue[]
                    }

                    $routeHost[${token.1}${mergedParams.[$token.3]}$routeHost]
                }{
                    $routeHost[${token.1}$routeHost]
                }
            }
            ^if($routeHost ne $host){
                $host[$routeHost]
#                ^if(http eq $scheme && 80 ne $env:SERVER_PORT){
#                    $port[:$env:SERVER_PORT] ^rem[$this->context->getHttpPort()]
#                }(https eq $scheme && 443 ne $env:SERVER_PORT){
#                    $port[:$env:SERVER_PORT] ^rem[$this->context->getHttpsPort()]
#                }
                ^if($self.ABSOLUTE_URL ne $referenceType){
                    $referenceType[$self.NETWORK_PATH]
                }
            }
        }
        ^if($self.ABSOLUTE_URL eq $referenceType || $self.NETWORK_PATH eq $referenceType){
            $port[]
#           TODO ADD routecontext which holds custom http and https ports
            $schemeAuthority[^if($self.NETWORK_PATH ne $referenceType){$scheme^:}//${host}$port]
        }
    }

    ^if($self.RELATIVE_PATH eq $referenceType){
        $url[^self.getRelativePath[$self.context.pathInfo;$url]]
    }{
        $url[${schemeAuthority}${self.context.baseUrl}$url]
    }

#   add a query string if needed
    $extra[^hash::create[$parameters]]
    ^extra.sub[$variables]
    ^extra.sub[$defaults]

    ^if($extra){
        $query[^extra.foreach[ekey;evalue]{$ekey^if(def $evalue){=^taint[uri][$evalue]}}[&]]
        $url[${url}?$query]
    }

    $result[$url]
###


@generateErrorMessage[parameter;route;expected;given][result]
    $message[Parameter "{parameter}" for route "{route}" must match "{expected}" ("{given}" given) to generate a corresponding URL.]

    $result[^message.replace[^table::create{from	to
{parameter}	$parameter
{route}	$route
{expected}	$expected
{given}	$given}]]
###



# Returns the target path as relative reference from the base path.
#
# Only the URIs path component (no schema, host etc.) is relevant and must be given, starting with a slash.
# Both paths must be absolute and not contain relative parts.
# Relative URLs from one resource to another are useful when generating self-contained downloadable document archives.
# Furthermore, they can be used to reduce the link size in documents.
#
# Example target paths, given a base path of "/a/b/c/d":
# - "/a/b/c/d"     -> ""
# - "/a/b/c/"      -> "./"
# - "/a/b/"        -> "../"
# - "/a/b/c/other" -> "other"
# - "/a/x/y"       -> "../../x/y"
#
#:param basePath string The base path
#:param targetPath string The target path
#
#:result string The relative target path
@getRelativePath[basePath;targetPath][result]
    $result[]
    ^if($basePath ne $targetPath){
        $t[^if(^basePath.mid(0;1) eq '/'){^basePath.mid(1;^basePath.length[]-1)}{$basePath}]
        $t[^t.match[\/[^^\/]+^$][i][]]
        $sourceDirs[^t.split[/]]

        $t[^if(^targetPath.mid(0;1) eq '/'){^targetPath.mid(1;^targetPath.length[]-1)}{$targetPath}]
        $targetFile[^t.match[\/([^^\/]+)^$][i]]
        $targetFile[$targetFile.1]

        $t[^t.match[\/[^^\/]+^$][i][]]
        $targetDirs[^t.split[/]]

        $startIndex(0)
        ^sourceDirs.foreach[index;row]{
            ^targetDirs.offset[set]($index)

            ^if(^targetDirs.offset[] ne $index || $row.piece ne $targetDirs.piece){
                ^break[]
            }{
                $startIndex($index)
            }
        }
        $str[]
        ^for[i](1;^sourceDirs.count[] - $startIndex - 1){
            $str[${str}../]
        }

        ^targetDirs.append[$targetFile]
        $path[$str^targetDirs.foreach[index;row]{^if($index > $startIndex){$row.piece}}[/]]

        $colonPos[^path.pos[:]]
        $slashPos[^path.pos[/]]
        ^if($path eq '' || ^path.mid(0;1) eq '/' || $colonPos > -1 && ($colonPos < $slashPos || $slashPos eq -1)){
            $result[./$path]
        }{
            $result[$path]
        }
    }
###
