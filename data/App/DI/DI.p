# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 23.04.16
# Time: 22:41
# To change this template use File | Settings | File Templates.

@CLASS
DI

@OPTIONS
locals


#------------------------------------------------------------------------------
#Dummiest mock for future di container implementation
#Sorry for name it DI, but someday we replace it by real IoC-container, I promise.
#------------------------------------------------------------------------------
@auto[]
    $DI:vaultDirName[vault]

    $self.registry[
        $.session[^Service::create[Session]]
        $.security[^Service::create[Security;
            $.0[session]
        ]]
        $.githubApi[^Service::create[GithubApi;
            $.0[security]
        ]]
        $.packageManager[^Service::create[PackageManager;
            $.0[githubApi]
            $.1[providerManager]
        ]]
        $.providerManager[^Service::create[ProviderManager]]
    ]
    $self.instances[^hash::create[]]
###


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
###


#------------------------------------------------------------------------------
#:param key type string
#------------------------------------------------------------------------------
@static:GET_DEFAULT[key][result]
    $result[^DI:getService[$key]]
###


#------------------------------------------------------------------------------
#Interlayer for GET_DEFAULT to avoid GET_DEFAULT impossibility recursion calls.
#
#:param key type string
#------------------------------------------------------------------------------
@static:getService[key]
    ^if(!^self.registry.contains[$key]){
        ^throw[service.unknown;container.p;Service $key not found]
    }
    ^if(!^self.instances.contains[$key]){
        $servise[$self.registry.$key]
        $params[^servise.services.foreach[i;name]{^^DI:getService[$name]}[^;]]
#       because reflection class cannot acept hash of params
#       ^reflection:create[$servise.class;create;-hash-here-]
        ^process{^$object[^^$servise.class^::create[$params]]}
        $self.instances.$key[$object]
    }

    $result[$self.instances.$key]
###
