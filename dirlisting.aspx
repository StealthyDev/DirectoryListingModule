<%@ Page Language="c#" %>
<%@ Import Namespace="Mvolo.DirectoryListing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    Boolean isRootAllowed = false;
    Boolean showHidden = false;
    String path = null;
    String parentPath = null;
    int count = 0;

    void Page_Load() {
        DirectoryListingEntryCollection listing =  Context.Items[DirectoryListingModule.DirectoryListingContextKey] as DirectoryListingEntryCollection;

        if (listing == null) {
            throw new Exception("This page cannot be used without the DirectoryListing module");
        }

        if(!showHidden) {
            ArrayList hidden = new ArrayList();
            foreach (DirectoryListingEntry entry in listing) {
                if ((entry.FileSystemInfo.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden) {
                    hidden.Add(entry);
                }
            }
            foreach (DirectoryListingEntry hiddenEntry in hidden) {
                listing.Remove(hiddenEntry);
            }
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
        String baseUrl = Request.Url.Scheme + "://" + Request.Url.Authority + Request.ApplicationPath.TrimEnd('/');
        String hyperlink = uriPrefix + baseUrl + dirEntry.VirtualPath;
        return hyperlink;
    }

    String GetPath() {
        String currentFolder = "";
        String[] foldersArray = Context.Request.Path.Split('/');
        if(foldersArray.Length > 0)
            currentFolder = foldersArray[foldersArray.Length - 1];
        if(currentFolder.Equals("")) currentFolder = Context.Request.Url.AbsolutePath;
        return currentFolder;
    }

    String GetFileIconCss(String extn) {
        String iconCss = "";
        switch(extn) {
            case ".pdf": iconCss = "file-pdf"; break;
            case ".docx":
            case ".doc": iconCss = "file-word"; break;
            case ".xlsx":
            case ".xls": iconCss = "file-excel"; break;
            case ".txt": iconCss = "file-alt"; break;
            default: iconCss = "file"; break;
        }
        if(extn.Length == 0) {
            iconCss = "folder";
        }
        return iconCss;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Directory contents of <%= Context.Request.Path %></title>
        <link rel="stylesheet" type="text/css" href="/static/datatables/datatables.min.css"/>
        <link rel="stylesheet" type="text/css" href="/static/fa/fontawesome-all.css"/>
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
            .dataTables_wrapper table thead{
                display:none;
            }
            .far {font-size: 20px; width: 25px;}
        </style>
        <script type="text/javascript" src="/static/datatables/datatables.min.js"></script>
        <script>
            $(document).ready(function(){
                $('#DirectoryListing').DataTable({
                    // "order": [[ 0, "asc" ]],
                    "ordering": false,
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
            <asp:HyperLink runat="server" id="NavigateUpLink">
                <img style="vertical-align:bottom" src="/static/level-up.png" />
                To Parent Directory
            </asp:HyperLink>
        </div>

        <form runat="server">
            <asp:Repeater ID="DirectoryListing" runat="server" EnableViewState="False">
                <HeaderTemplate>
                    <table id="DirectoryListing" style="width:1000px; text-align:left; margin-left: 0px;">
                        <thead>
                        <tr>
                            <th>Name</th>
                        </tr>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <i class="far fa-<%# GetFileIconCss(Path.GetExtension(((DirectoryListingEntry)Container.DataItem).Path)) %>"></i>
                            <a href="<%# GetHyperLink((DirectoryListingEntry)Container.DataItem) %>"><%# ((DirectoryListingEntry)Container.DataItem).Filename %></a>
                        </td>
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