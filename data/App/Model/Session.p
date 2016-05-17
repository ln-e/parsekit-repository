# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 18:49
# To change this template use File | Settings | File Templates.

@CLASS
Session

@OPTIONS
locals

@auto[]
    ^if(!def $cookie:sessionID){
        $cookie:sessionID[^math:uuid[]]
    }
    $self.sessionID[$cookie:sessionID]
    $self.sessions[^hashfile::open[../data/sessions]]
###


@create[]
###


@GET_DEFAULT[key][result]
    ^if(def $self.sessions.[$self.sessionID]){
        $data[^hash::create[^json:parse[^taint[as-is][$self.sessions.[$self.sessionID]]]]]

        $result[$data.$key]
    }{
        $result[]
    }
###


@SET_DEFAULT[key;value][result]
    $result[]
    ^try{
        $data[^hash::create[^json:parse[$self.sessions.$sessionID]]]
    }{
        $exception.handled(1)
        $data[^hash::create[]]
    }
    $data.$key[$value]
    $self.sessions.$sessionID[^json:string[$data]]
###
