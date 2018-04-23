<%@ Page Language="c#" %>
<%@ Import Namespace="Mvolo.DirectoryListing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    Boolean isRootAllowed = false;
    String path = null;
    String parentPath = null;
    int count = 0;

    void Page_Load() {
        DirectoryListingEntryCollection listing =  Context.Items[DirectoryListingModule.DirectoryListingContextKey] as DirectoryListingEntryCollection;

        if (listing == null) {
            throw new Exception("This page cannot be used without the DirectoryListing module");
        }

        DirectoryListing.DataSource = listing;
        DirectoryListing.DataBind();

        FileCount.Text = listing.Count + " items.";

        path = VirtualPathUtility.AppendTrailingSlash(Context.Request.Path);
        if (path.Equals("/") || path.Equals(VirtualPathUtility.AppendTrailingSlash(HttpRuntime.AppDomainAppVirtualPath))) {
            parentPath = null;
        }
        else {
            parentPath = VirtualPathUtility.Combine(path, "..");
            if(!isRootAllowed && parentPath.Equals("/")) parentPath = null;
        }

        if (String.IsNullOrEmpty(parentPath)) {
            NavigateUpLink.Visible = false;
            NavigateUpLink.Enabled = false;
        }
        else {
            NavigateUpLink.NavigateUrl = parentPath;
        }
    }

    String GetFileModifiedString(FileSystemInfo info){
        if (info is FileInfo) {
            return ((FileInfo)info).LastWriteTime.ToString();
        }
        else {
            return String.Empty;
        }
    }

    String GetFileSizeString(FileSystemInfo info){
        if (info is FileInfo) {
            long lengthInK = ((FileInfo)info).Length / 1024;
            return lengthInK.ToString("N0") + " KB";
        }
        else {
            return String.Empty;
        }
    }

    String GetUriPrefix(String fileExtension) {
        fileExtension = fileExtension.ToLower();
        if(fileExtension.Equals(".docx") || fileExtension.Equals(".doc")) return "ms-word:ofv|u|";
        if(fileExtension.Equals(".xls") || fileExtension.Equals(".xlsx")) return "ms-excel:ofv|u|";
        if(fileExtension.Equals(".ppt") || fileExtension.Equals(".pptx")) return "ms-powerpoint:ofv|u|";
        return "";
    }

    String GetHyperLink(DirectoryListingEntry dirEntry) {
        String extension = Path.GetExtension(dirEntry.Path);
        String uriPrefix = GetUriPrefix(extension);
        String baseUrl = new Uri(HttpContext.Current.Request.Url, "/").ToString();
        String hyperlink = uriPrefix + baseUrl + dirEntry.VirtualPath;
        return hyperlink;
    }

    String GetPath() {
        String currentFolder = "";
        String[] foldersArray = Context.Request.Path.Split('/');
        if(foldersArray.Length > 0)
            currentFolder = foldersArray[foldersArray.Length - 1];
        if(currentFolder == "") currentFolder = Context.Request.ApplicationPath;
        return Context.Request.Url.AbsolutePath;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Directory contents of <%= Context.Request.Path %></title>
        <link rel="stylesheet" type="text/css" href="/static/datatables/datatables.min.css"/>
        <style type="text/css">
            a { text-decoration: none; }
            a:hover { text-decoration: underline; }
            p {font-family: verdana; font-size: 10pt; }
            h2 {font-family: verdana; margin:0px;}
            table {width:800px; text-align:left; margin-left: 0px; border: 0px;}
            td {font-family: verdana; font-size: 10pt; }
            th:nth-child(odd), td:nth-child(odd) {background-color: #f9f9f9;}
            td {border-top:1pt solid #dddddd;}
            th {border-top:1pt solid #dddddd;}
            th:first-child, td:first-child {border-left:1pt solid #dddddd;}
            th:last-child, td:last-child {border-right:1pt solid #dddddd;}
        </style>
        <script type="text/javascript" src="/static/datatables/datatables.min.js"></script>
        <script>
            $(document).ready(function(){
                $('#DirectoryListing').DataTable({
                    "order": [[ 0, "asc" ]],
                    "paging":   false,
                    "info":     false,
                    "searching": false,
                    "autoWidth": false
                });
            });
        </script>
    </head>
    <body>
    <% if(!path.Equals("/") || (path.Equals("/") & isRootAllowed)) { %>
        <div style="height:80px;">
            <h2><%= GetPath() %> </h2>
            <!--%=VirtualPathUtility.AppendTrailingSlash(HttpRuntime.AppDomainAppVirtualPath)%-->
            <asp:HyperLink runat="server" id="NavigateUpLink">
                <img style="vertical-align:bottom" src="/static/level-up.png" />
                To Parent Directory
            </asp:HyperLink>
        </div>

        <form runat="server">
            <asp:Repeater ID="DirectoryListing" runat="server" EnableViewState="False">
                <HeaderTemplate>
                    <table id="DirectoryListing" style="width:1000px; text-align:left; margin-left: 0px;">
                        <col width="650">
                        <col width="225">
                        <col width="125">
                        <thead>
                        <tr>
                            <th>Name</th>
                            <th>Modified</th>
                            <th>Size</th>
                        </tr>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <img alt="icon" src="/geticon.axd?file=<%# Path.GetExtension(((DirectoryListingEntry)Container.DataItem).Path) %>&size=small" />
                            <a href="<%# GetHyperLink((DirectoryListingEntry)Container.DataItem) %>"><%# ((DirectoryListingEntry)Container.DataItem).Filename %></a>
                        </td>
                        <td><%# GetFileModifiedString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %></td>
                        <td><%# GetFileSizeString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <p>
                <asp:Label runat="Server" id="FileCount" />
            </p>
        </form>
        <% } else { %>
            Access denied!
        <% } %>
    </body>
</html>