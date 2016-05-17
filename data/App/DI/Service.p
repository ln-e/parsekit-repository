# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 02.05.16
# Time: 20:44
# To change this template use File | Settings | File Templates.

@CLASS
Service

@OPTIONS
locals

@auto[]
###


#------------------------------------------------------------------------------
#:param class type string
#:param arguments type hash optional
#------------------------------------------------------------------------------
@create[class;services]
    $self.class[$class]
    $self.services[^if($services is hash){$services}{^hash::create[]}]
###


#------------------------------------------------------------------------------
#:param service type Service
#------------------------------------------------------------------------------
@addService[service][result]
    $ind[^services._count[]]
    $self.services.$ind[$service]
###