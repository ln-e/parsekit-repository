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
    $message = 'Parameter "{parameter}" for route "{route}" must match "{expected}" ("{given}" given) to generate a corresponding URL.';
    ^tokens.foreach[ind;token]{
        ^if('variable' eq $token.0){
            ^throw[NotImplementedYet]
        }{
#           static text
            $url[${token.1}$url]
            $optional(false)
        }
    }
###