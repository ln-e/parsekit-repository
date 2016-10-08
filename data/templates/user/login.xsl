<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />


    <xsl:template match="*" mode="body">

        <div class="container">

            <form class="form-signin">
                <img src="//www.parser.ru/f/1/ptic.gif" alt="" height="189" width="100" />

                <xsl:if test="error">
                    <div class="alert alert-danger">
                        <xsl:value-of select="error"/>
                    </div>
                </xsl:if>
                <h2 class="form-signin-heading">Sign in</h2>
                <label for="inputEmail" class="sr-only">Email address</label>
                <input disabled="disabled" type="email" id="inputEmail" class="form-control" placeholder="Email address" required="" autofocus="" />
                <label for="inputPassword" class="sr-only">Password</label>
                <input disabled="disabled" type="password" id="inputPassword" class="form-control" placeholder="Password" required="" />
                <div class="checkbox">
                    <label>
                        <input disabled="disabled" type="checkbox" value="remember-me" /> Remember me
                    </label>
                </div>
                <buton disabled="disabled" class="btn btn-primary" type="submit">Login</buton>
                or
                <a class="btn btn-primary" href="https://github.com/login/oauth/authorize?scope=user:email,write:repo_hook&amp;client_id={github_client_id}">
                    <i class="fa fa-github"/> Github
                </a>
            </form>
        </div>

    </xsl:template>
</xsl:stylesheet>