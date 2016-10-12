# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 20:05
# To change this template use File | Settings | File Templates.

@CLASS
PackagesController

@OPTIONS
locals

@BASE
BaseController

@auto[]
###


@create[]
    $self.security[$DI:security]
    $self.githubApi[$DI:githubApi]
    $self.providerManager[$DI:providerManager]
    $self.packageManager[$DI:packageManager]
###


@allAction[]
    ^connect[$MAIN:SQL.connect-string]{
        $packages[^hash::sql{
            SELECT p.id, p.* FROM package as p
        }[$.limit(10)]]
    }

    $data[
        $.packages[$packages]
    ]

    $result[^self.render[$data;../data/templates/packages/all.xsl]]
###


@listAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }{
        $user[^self.security.getUser[]]
        ^connect[$MAIN:SQL.connect-string]{
            $packages[^hash::sql{
                SELECT p.id, p.* FROM package as p
                LEFT JOIN package_user as pu ON p.id = pu.package_id
                WHERE pu.user_id = $user.id
            }]
        }

        $data[
            $.packages[$packages]
        ]

        $result[^self.render[$data;../data/templates/packages/list.xsl]]
    }
###


@deleteAction[id]
    ^if(!^self.security.isGranted[ROLE_ADMIN]){
        ^self.redirect[^self.generateUrl[package_show;$.id[$id]]]
    }{

        ^connect[$MAIN:SQL.connect-string]{
            $package[^hash::sql{
                SELECT p.id, p.* FROM package as p
                WHERE p.id = $id
            }]
            $packages[^void:sql{
                DELETE FROM package WHERE package.id = $id
            }]

            ^self.packageManager.removePackage[$package]
        }

        ^self.redirect[^self.generateUrl[package]]
    }
###


@showAction[id]
    $user[^self.security.getUser[]]
    ^connect[$MAIN:SQL.connect-string]{
        $packages[^hash::sql{
            SELECT p.* FROM package as p
            WHERE p.id = $id
        }]

        $package[^packages._at(0)]
        $keys[^packages._keys[key]]
        $package.id[$keys.key]

        ^if(!def $package){
            ^throw[NotFoundException;;Package with id "$id" not found]
        }
    }

    ^connect[$MAIN:SQL.connect-string]{
        $versions[^hash::sql{
            SELECT v.* FROM version as v
            WHERE v.package_id = $id
        }]
    }

    $data[
        $.package[$package]
    ]
    $data.package.versions[$versions]

    ^if(^self.security.isGranted[ROLE_ADMIN]){
        $data.package.deleteUrl[^self.generateUrl[package_delete;$.id[$package.id]]]
    }

    $result[^self.render[$data;../data/templates/packages/show.xsl]]
###


@searchAction[]
    $query[$form:fields.q]

    $r[^hash::create[]]
    $r.protocol[$MAIN:protocol]
    $r.query[$query]


    ^if(!def $query){
        $r.packages[^hash::create[]]
        $r.error[Query is not specified]
    }{
        ^connect[$MAIN:SQL.connect-string]{
            $packages[^table::sql{
                SELECT
                  p.name
                FROM
                  package as p
                WHERE
                  p.name like '%${query}%'
                  OR p.keywords like '%$query%'
            }]
        }

        $r.packages[$packages]
    }

    $response:content-type[Application/json]
    $result[^json:string[$r;$.indent(true)]]
###


@addAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }{
        $user[^self.security.getUser[]]
        $repoName[^taint[as-is][$form:fields.package]]
        $hookData[^self.githubApi.createRepoHook[$repoName]]
        $parsekit[^self.githubApi.getParsekitFile[$repoName;master]]

        ^if(!def $hookData.id){
            ^throw[CouldNotCreateHookException;;Hook creation failed: ^json:string[$hookData]]
        }

        $readmeFile[^self.githubApi.getSourceFile[$repoName;master;README.md]]

        ^connect[$MAIN:SQL.connect-string]{
            $packageName[^if(!def $parsekit.name || ^parsekit.name.trim[] eq ''){$repoName}{$parsekit.name}]
            $r[^void:sql{
                INSERT INTO package(hook_id,name,repository_url,repository_name,target_dir,type,description,keywords,readme)
                VALUES(
                    $hookData.id,
                    '$packageName',
                    'https://github.com/$repoName',
                    '$repoName',
                    '$packageName',
                    '$parsekit.type',
                    '$parsekit.description',
                    '^if($parsekit.keywords is hash){^parsekit.keywords.foreach[i;keyword]{$keyword}[,]}{ }',
                    '$readmeFile.text'
                )
            }]

            $packageId[^int:sql{SELECT last_insert_id()}]

            $r[^void:sql{
                INSERT INTO package_user(user_id,package_id)
                VALUES($user.id, $packageId)
            }]
        }

        $r[^self.providerManager.dumpProvider[^self.providerManager.providerKeyByPackage[$packageId]]]
        ^self.githubApi.ping[$packageName;$hookData.id]
        ^self.redirect[/package/$packageId]
    }
###
