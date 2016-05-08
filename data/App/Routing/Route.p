# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 9:42
# To change this template use File | Settings | File Templates.

@CLASS
Route

@OPTIONS
locals

@auto[]
###


@create[path;defaults;requirements;methods]
    ^if(
        !def $path || !($path is string) ||
        (def $defaults && !($defaults is hash)) ||
        (def $requirements && !($requirements is hash)) ||
        (def $methods && !($methods is hash))
    ){
        ^throw[InvalidArgumentException;;Route accept string^;hash^;hash^;hash arguments]
    }
    $self.path[$path]
    $self.defaults[$defaults]
    $self.requirements[$requirements]
    $self.methods[$methods]
    $self.compiled[]
###


@compile[][result]
    ^if(!def $self.compiled){
        $compiler[^RouteCompiler::create[]]
        $self.compiled[^compiler.compile[$self]]
    }

    $result[$self.compiled]
###
