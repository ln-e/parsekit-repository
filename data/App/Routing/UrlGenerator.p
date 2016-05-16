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
    $self.ABSOLUTE_PATH(0)
###


@create[routes]
    $self.routes[$routes]
###


@generate[name;params;referenceType][result]
    ^if(!def $referenceType){
        $referenceType[$self.ABSOLUTE_PATH]
    }
    $route[$this.routes.$name]
    ^if(!def $route){
        ^throw[RouteNotFoundException;;Unable to generate a URL for the named route "$name" as such route does not exist.]
    }

    $compiledRoute[^route.compile[]]
    $result[^self.doGenerate[$compiledRoute.variables;$route.defaults;$route.requirements;$compiledRoute.tokens;$parameters;$name;$referenceType;$compiledRoute.hostTokens;$route.schemes]]
###


@doGenerate[variables;defaults;requirements;tokens;parameters;name;referenceType;hostTokens;requiredSchemes]
    ^throw[NotImplementedYet]

    ^if(!($requiredSchemes is hash)){ $requiredSchemes[^hash::create[]]}
    $mergedParams[^parameters.union[$defaults]]
    $diff[^hash::create[$mergedParams]]
    ^diff.sub[$variables]
    ^if(^diff._count[] > 0){
        ^throw[MissingMandatoryParametersException;;Some mandatory parameters are missing ("^diff.foreach[$key;$value]{$key}[, ]") to generate a URL for route "$name"]
    }

    $url[]
    $optional(true)
    ^tokens.foreach[ind;token]{
        ^if('variable' eq $token.0){
            ^if(
                !$optional
                || !^defaults.containts[$token.3]
                || !def $mergedParams.[$token.3]
                && $mergedParams.[$token.3] eq $defaults.[$token.3]
            ){
                ^if(def $self.strictRequirements && ^mergedParams.[$token.3].match[^^$token.2^$][in] <=0){
                    ^if($self.strictRequirements){
                        ^throw[InvalidParameterException;;^self.generateErrorMessage[$token.3;$name;$token.2;$mergedParams[$token.3]]]
                    }
                    ^continue[]
                }
                $url[${token.1}${mergedParams[$token.3]}$url]
                $optional(false)
            }
            ^throw[NotImplementedYet]
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
            }
        }
        ^if(def $hostTokens && $hostTokens is hash){
            $routeHost[]
            ^hostTokens.foreach[k;token]{
                ^if(variable eq $token.0) {
                    ^if(def $self.strictRequirements && ^mergedParams.[$token.3].match[^^$token.2^$][in] <=0){
                        ^if($self.strictRequirements){
                            ^throw[InvalidParameterException;;^self.generateErrorMessage[$token.3;$name;$token.2;$mergedParams[$token.3]]]
                        }
                        ^continue[]
                    }

                    $routeHost[${token.1}${mergedParams.[$token.3]}$routeHost]
                }{
                    $routeHost[${token.1}$routeHost]
                }
            }
            ^if($routeHost !== $host){
                $host[$routeHost]
                ^if($self.ABSOLUTE_URL ne $referenceType){
                    $referenceType[^self.NETWORK_PATH]
                }
            }
        }
        ^if($self.ABSOLUTE_URL eq $referenceType || $self.NETWORK_PATH eq $referenceType) {
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
        $query[$extra.foreach[ekey;evalue]{$ekey=^taint[uri][$evalue]}[&]]
        $url[${url}?$query]
    }

    $result[$url]
###


@generateErrorMessage[parameter;route;expected;given][result]
    $message[Parameter "{parameter}" for route "{route}" must match "{expected}" ("{given}" given) to generate a corresponding URL.]

    $result[$message.replace[^table::create{from	to
{parameter}	$parameter
{route}	$route
{expected}	$expected
{given}	$mergedParams[$given]}]]
###
