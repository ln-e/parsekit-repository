# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 15.05.16
# Time: 11:32
# To change this template use File | Settings | File Templates.

@CLASS
RequestContext

@OPTIONS
locals

@auto[]
###

@create[baseUrl;method;host;scheme;httpPort;httpsPort;path;queryString]

    $defaultBaseUrl[]
    $defaultMethod[GET]
    $defaultHost[localhost]
    $defaultScheme[http]
    $defaultHttpPort[80]
    $defaultHttpsPort[443]
    $defaultPath[/]
    $defaultQueryString[]

    $self.baseUrl[$baseUrl]
    $self.method[^if(!def $method){$defaultMethod}{$method}]
    $self.host[^if(!def $host){$defaultHost}{$host}]
    $self.scheme[^if(!def $scheme){$defaultScheme}{$scheme}]
    $self.httpPort[^if(!def $httpPort){$defaultHttpPort}{$httpPort}]
    $self.httpsPort[^if(!def $httpsPort){$defaultHttpsPort}{$httpsPort}]
    $self.path[^if(!def $path){$defaultPath}{$path}]
    $self.queryString[$queryString]
###
