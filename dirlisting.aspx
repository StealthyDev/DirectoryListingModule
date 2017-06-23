<%@ Page Language="c#" %>
<%@ Import Namespace="Mvolo.DirectoryListing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
void Page_Load()
{
    String path = null;
    String parentPath = null;
    int count = 0;
    String sortBy = Request.QueryString["sortby"];
    
    //
    // Databind to the directory listing
    //
    DirectoryListingEntryCollection listing = 
        Context.Items[DirectoryListingModule.DirectoryListingContextKey] as DirectoryListingEntryCollection;
    
    if (listing == null)
    {
        throw new Exception("This page cannot be used without the DirectoryListing module");
    }

    //
    // Handle sorting
    //
    if (!String.IsNullOrEmpty(sortBy))
    {
        if (sortBy.Equals("name"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileNames);
        }
        else if (sortBy.Equals("namerev"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileNamesReverse);
        }            
        else if (sortBy.Equals("date"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModified);        
        }
        else if (sortBy.Equals("daterev"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModifiedReverse);        
        }
        else if (sortBy.Equals("size"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizes);
        }
        else if (sortBy.Equals("sizerev"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizesReverse);
        }
    }

    DirectoryListing.DataSource = listing;
    DirectoryListing.DataBind();

    //
    //  Prepare the file counter label
    //
    FileCount.Text = listing.Count + " items.";

    //
    //
    //  Parepare the parent path label
    path = VirtualPathUtility.AppendTrailingSlash(Context.Request.Path);
    if (path.Equals("/") || path.Equals(VirtualPathUtility.AppendTrailingSlash(HttpRuntime.AppDomainAppVirtualPath)))
    {
        // cannot exit above the site root or application root
        parentPath = null;
    }
    else
    {
        parentPath = VirtualPathUtility.Combine(path, "..");
    }
    
    if (String.IsNullOrEmpty(parentPath))
    {
        NavigateUpLink.Visible = false;
        NavigateUpLink.Enabled = false;
    }
    else
    {
        NavigateUpLink.NavigateUrl = parentPath;
    }
}

String GetFileSizeString(FileSystemInfo info)
{
    if (info is FileInfo)
    {
        return String.Format("{0}K", ((int)(((FileInfo)info).Length * 10 / (double)1024) / (double)10));
    }
    else
    {
        return String.Empty;
    }
}
String GetUriPrefix(String fileExtension)
{
    fileExtension = fileExtension.ToLower();
    if(fileExtension.Equals(".docx") || fileExtension.Equals(".doc")) return "ms-word:ofv|u|";
    if(fileExtension.Equals(".xls") || fileExtension.Equals(".xlsx")) return "ms-excel:ofv|u|";
    if(fileExtension.Equals(".ppt") || fileExtension.Equals(".pptx")) return "ms-powerpoint:ofv|u|";
    return "";
}
String GetHyperLink(DirectoryListingEntry dirEntry)
{
    String extension = Path.GetExtension(dirEntry.Path);
    String uriPrefix = GetUriPrefix(extension);
    String baseUrl = new Uri(HttpContext.Current.Request.Url, "/").ToString();
    String hyperlink = uriPrefix + baseUrl + dirEntry.VirtualPath;

    return hyperlink;
}
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Directory contents of <%= Context.Request.Path %></title>
        <style type="text/css">
            a { text-decoration: none; }
            a:hover { text-decoration: underline; }
            p {font-family: verdana; font-size: 10pt; }
            h2 {font-family: verdana; }
            td {font-family: verdana; font-size: 10pt; }                           
        </style>
    </head>
    <body>
        <h2><%= Context.Request.Path %> <asp:HyperLink runat="server" id="NavigateUpLink">[..]</asp:HyperLink></h2>
        <p>
        <a href="?sortby=name">sort by name</a>/<a href="?sortby=namerev">-</a> |
        <a href="?sortby=date">sort by date</a>/<a href="?sortby=daterev">-</a> |
        <a href="?sortby=size">sort by size</a>/<a href="?sortby=sizerev">-</a>        
        </p>
        <form runat="server">
            <hr />
            <asp:DataList id="DirectoryListing" runat="server">
                <HeaderTemplate>
                   <td><h3>Files and folders</h3></td>
                </HeaderTemplate>
                <ItemTemplate>
                    <td>
                        <span style="float: left; width: 100px;"><%# GetFileSizeString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %></span>
                        <img alt="icon" src="/geticon.axd?file=<%# Path.GetExtension(((DirectoryListingEntry)Container.DataItem).Path) %>" />
                        <a href="<%# GetHyperLink((DirectoryListingEntry)Container.DataItem) %>"><%# ((DirectoryListingEntry)Container.DataItem).Filename %></a>
                    </td>
                </ItemTemplate>
            </asp:DataList>
            <hr />
            <p>
                <asp:Label runat="Server" id="FileCount" />
            </p>
        </form>
    </body>
</html>