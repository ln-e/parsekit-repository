# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 9:44
# To change this template use File | Settings | File Templates.

@CLASS
Matcher

@OPTIONS
locals

@auto[]
    $self.REQUIREMENT_MATCH[0]
    $self.REQUIREMENT_MISMATCH[1]
    $self.ROUTE_MATCH[2]
###


@create[routes]
    ^if(!($routes is hash)){
        $routes[^hash::create[]]
    }
    $self.routes[$routes]

    $self.allow[^hash::create[]]
###


@match[path][result]
    $self.allow[^hash::create[]]

    $ret[^self.matchCollection[$path;$self.routes]]

    ^if(!def $ret){
        ^if(0 < ^self.allow._count[]){
            ^throw[MethodNotAllowedException;;Available method ^self.allow.foreach[i;k]{$k}[,]]
        }{
            ^throw[RouteNotFoundException;;No route found for "$path"]
        }
    }

    $result[$ret]
###


@matchCollection[path;routes][result]
    ^routes.foreach[name;route]{

        $compiledRoute[^route.compile[]]

        ^if(def $compiledRoute.staticPrefix && ^path.pos[$compiledRoute.staticPrefix] != 0){
            ^continue[]
        }

        $matchesTable[^path.match[^apply-taint[$compiledRoute.regex]][$compiledRoute.regexModefiers]]
        ^if(!def $matchesTable){
            ^continue[]
        }
        $matches[^hash::create[]]
        $i(0)
        ^compiledRoute.matchesOrder.foreach[matchName;value]{
            ^i.inc[]
            $matches.$matchName[$matchesTable.$i]
        }

        ^if(def $compiledRoute.hostRegex){
            $hostMatchesTable[^env:fields.SERVER_NAME.match[^apply-taint[$compiledRoute.hostRegex]]]
            ^if(!def $hostMatchesTable){
                ^continue[]
            }
            $i(0)
            ^compiledRoute.hostMatchesOrder.foreach[matchName;value]{
                ^i.inc[]
                $hostMatches.$matchName[$hostMatchesTable.$i]
            }
        }{
            $hostMatches[^hash::create[]]
        }


#       check HTTP method requirement
        ^if(def $route.methods){
#           HEAD and GET are equivalent as per RFC
            $method[$request:method]
            ^if('HEAD' eq $method){
                $method['GET']
            }
            ^if(!^requiredMethods.contains[$method]){
                ^self.allow.add[$requiredMethods]
                ^continue[]
            }
        }

        $status[^self.handleRouteRequirements[$path;$name;$route]]
        ^if($self.REQUIREMENT_MISMATCH == $status.0){
            ^continue[]
        }

        ^if($self.ROUTE_MATCH == $status.0){
            $result[$status.1]
        }{
            $result[^self.getAttributes[$route;$name;^hostMatches.union[$matches]]]
        }
    }
###


@getAttributes[route;name;attributes][result]
    $attributes._route[$name]
    $result[^self.mergeDefaults[$attributes;$route.defaults]]
###


@handleRouteRequirements[path;name;route][result]
#   check HTTP scheme requirement
    $scheme[^if(def $env:HTTPS){https}{http}]
    $status[^if($route.schemes && !^route.hasScheme[$scheme]){$self.REQUIREMENT_MISMATCH}{$self.REQUIREMENT_MATCH}]

    $result[
        $.0[$status]
        $.1[]
    ]
###


@mergeDefaults[params;defaults][result]
    $result[^hash::create[$defaults]]
    ^params.foreach[key;value]{
        $result.$key[$value]
    }
###
