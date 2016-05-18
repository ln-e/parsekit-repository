<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:template name="body_inner">
        <div class="uk-grid" data-uk-grid-margin="">
            <div class="uk-width-medium-1-1 uk-row-first">

                <table class="uk-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Keywords</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="packages/package" mode="packages_list" />
                    </tbody>
                </table>

                <form action="/package/add" class="uk-form">
                    <fieldset data-uk-margin="">
                        <input type="text" name="package" placeholder="vendor/name" />
                        <button type="submit" class="uk-button uk-button-primary">Add package</button>
                    </fieldset>
                </form>

            </div>
        </div>
    </xsl:template>


    <xsl:template match="package" mode="packages_list">
        <tr>
            <td>
                <xsl:value-of select="position()"/>
            </td>
            <td>
                <xsl:value-of select="name"/>
            </td>
            <td>
                <xsl:value-of select="type"/>
            </td>
            <td>
                <xsl:value-of select="description"/>
            </td>
            <td>
                <xsl:value-of select="keywords"/>
            </td>
            <td>
                <a href="package/{id}">show</a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
