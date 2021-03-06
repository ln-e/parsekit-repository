<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />

    <xsl:template name="page_title">Users</xsl:template>

    <xsl:template name="body_inner">
        <div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>id</th>
                        <th>email</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="users/item" mode="users_list" />
                </tbody>
            </table>
        </div>
    </xsl:template>


    <xsl:template match="item" mode="users_list">
        <tr>
            <td>
                <a href="user/{id}">
                    <xsl:value-of select="id"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="email"/>
            </td>
        </tr>
    </xsl:template>


</xsl:stylesheet>
