<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="_base.xsl" />


    <xsl:template match="*" mode="body">
        <xsl:attribute name="class">uk-height-1-1</xsl:attribute>



        <div class="uk-vertical-align uk-text-center uk-height-1-1">
            <div class="uk-vertical-align-middle" style="width: 250px;">

                <img class="uk-margin-bottom" src="//www.parser.ru/f/1/ptic.gif" alt="" height="189" width="100" />

                <xsl:if test="error">
                    <div class="uk-alert uk-alert-danger">
                        <xsl:value-of select="error"/>
                    </div>
                </xsl:if>

                <form class="uk-panel uk-panel-box uk-form">
                    <div class="uk-form-row">
                        <input class="uk-width-1-1 uk-form-large" placeholder="Username" type="text" />
                    </div>
                    <div class="uk-form-row">
                        <input class="uk-width-1-1 uk-form-large" placeholder="Password" type="text" />
                    </div>
                    <div class="uk-form-row">
                        <div class="uk-button-group">
                            <buton type="submit" class="uk-button uk-button-large">
                                Login
                            </buton>
                            <a href="https://github.com/login/oauth/authorize?scope=user:email,write:repo_hook&amp;client_id=e0a9aa67dbb28d792909" class="uk-button uk-button-large">
                                <i class="uk-icon-github"/> Github
                            </a>
                        </div>
                    </div>
                    <div class="uk-form-row uk-text-small">
                        <label class="uk-float-left"><input type="checkbox" /> Remember Me</label>
                        <a class="uk-float-right uk-link uk-link-muted" href="#">Forgot Password?</a>
                    </div>
                </form>

            </div>
        </div>

    </xsl:template>
</xsl:stylesheet>