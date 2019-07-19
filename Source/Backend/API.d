module API;

import std.algorithm : canFind, filter, map;
import std.container : Array, SList;
import std.array : array, split;
import std.process : executeShell;
import std.string : indexOf;
import std.regex: Regex, regex;
import std.file : dirEntries, SpanMode, DirEntry, readText, FileException;
import std.path : buildPath;
import std.conv: to;

import Utils : readListFiles;
import Logger : Logger;
import Crawler : Crawler;
import FileInfo : FileInfo;

immutable(string) DRILL_VERSION = import("DRILL_VERSION");
immutable(string) DRILL_BUILD_TIME = __TIMESTAMP__;
immutable(string) DRILL_GITHUB_URL = "https://github.com/yatima1460/Drill";
immutable(string) DRILL_WEBSITE_URL = "https://www.drill.santamorena.me";
immutable(string) DRILL_AUTHOR_URL = "https://www.linkedin.com/in/yatima1460/";
immutable(string) DRILL_AUTHOR_NAME = "Federico Santamorena";

struct drill_data
{
    immutable(string) ASSETS_DIRECTORY;
    immutable(string[]) BLOCK_LIST;
    immutable(string[]) PRIORITY_LIST;
    const(Regex!char[]) PRIORITY_LIST_REGEX;
    bool singlethread;
}

struct drill_context
{
    immutable(string) search_value;
    SList!Crawler threads;
}

/**
A crawler is active when it's scanning something.
If a crawler cleanly finished its job it's not considered active.
If a crawler crashes (should never happen) it's not considered active.
Minimum: 0
Maximum: length of total number of mountpoints unless the user started the crawlers manually

Returns: number of crawlers active

*/
@nogc @safe immutable(uint) drill_active_crawlers_count(drill_context context)
{
    int active = 0;
    foreach (thread; context.threads)
    {
        if (thread.isCrawling())
            active++;
    }
    return active;
}

/*
Notifies the crawlers to stop and clears the crawlers array stored inside DrillAPI
This function is non-blocking.
If no crawling is currently underway this function will do nothing.
*/
void drill_stop_crawling_async(drill_context context)
{
    foreach (Crawler crawler; context.threads)
        crawler.stopAsync();
    context.threads.clear(); // TODO: if nothing has a reference to a thread does the thread get GC-ed?
}


void drill_wait_for_crawlers(drill_context context)
{
    Logger.logInfo("Waiting for "~to!string(drill_active_crawlers_count(context))~" crawlers to stop");
    foreach (Crawler crawler; context.threads)
    {
        Logger.logInfo("Waiting for crawler "~to!string(crawler)~" to stop");
        import core.thread : ThreadException;
        try
        {
            crawler.join();
            Logger.logInfo("Crawler "~to!string(crawler)~" stopped");
        }
        catch(ThreadException e)
        {
            Logger.logError("Thread "~crawler.toString()~" crashed when joining");
            Logger.logError(e.msg);
        }
        
    }
    Logger.logInfo("All crawlers stopped.");
}

/*

*/
void drill_stop_crawling_sync(drill_context context)
{
    foreach (Crawler crawler; context.threads)
        crawler.stopAsync();
    drill_wait_for_crawlers(context);
}

/*
Starts the crawling returning a drill_context object
*/
drill_context drill_start_crawling(drill_data data, immutable(string) search_value, void function(immutable(FileInfo) result, void* user_object) result_callback, void* user_object)
{
    drill_context c = {search_value};
    if (user_object is null)
        throw new Exception("it does not make sense for a userObject to be null");
    
    foreach (immutable(string) mountpoint; DrillAPI.getMountPoints())
    {
        Crawler crawler = new Crawler(mountpoint, data.BLOCK_LIST, data.PRIORITY_LIST_REGEX, result_callback, search_value,user_object);
        if (data.singlethread)
            crawler.run();
        else
            crawler.start();
        c.threads.insertFront(crawler);
    }
    return c;
}

/*
Loads Drill data to be used in any crawling
*/
drill_data drill_load_data(immutable(string) assets_directory)
{
    Logger.logDebug("DrillAPI " ~ DRILL_VERSION);
    Logger.logDebug("Mount points found: "~to!string(DrillAPI.getMountPoints()));
    auto blockListsFullPath = buildPath(assets_directory,"BlockLists");


    Logger.logDebug("Assets Directory: " ~ assets_directory);
    Logger.logDebug("blockListsFullPath: " ~ blockListsFullPath);

    string[] BLOCK_LIST; 

    try
    {
        BLOCK_LIST = readListFiles(blockListsFullPath);
    }
    catch (FileException fe)
    {
        Logger.logError(fe.toString());
        Logger.logError("Error when trying to load block lists, will default to an empty list");
    }

    string[] PRIORITY_LIST;
    Regex!char[] PRIORITY_LIST_REGEX;

    try
    {
        PRIORITY_LIST = readListFiles(buildPath(assets_directory,"PriorityLists"));
        PRIORITY_LIST_REGEX = PRIORITY_LIST[].map!(x => regex(x)).array;
    }
    catch (FileException fe)
    {
        Logger.logError(fe.toString());
        Logger.logError("Error when trying to read priority lists, will default to an empty list");
    }

    drill_data dd = 
    {
        assets_directory,
        cast(immutable(string[]))BLOCK_LIST,
        cast(immutable(string[]))PRIORITY_LIST,
        PRIORITY_LIST_REGEX
    };
    return dd;
}




class DrillAPI
{

    unittest
    {
        DrillAPI drill = new DrillAPI("../../Assets");
        assert(drill.DRILL_VERSION == readText("../../DRILL_VERSION"));
        assert(drill.PRIORITY_LIST == readListFiles("../../Assets/PriorityLists"));
        assert(drill.BLOCK_LIST == readListFiles("../../Assets/BlockLists"));
        assert(drill.PRIORITY_LIST_REGEX.length != 0);
    }


private:

    Array!Crawler threads;

    immutable(string[]) BLOCK_LIST;
    immutable(string[]) PRIORITY_LIST;
    const(Regex!char[]) PRIORITY_LIST_REGEX;
    bool singlethread;

public:
    static immutable(string) DRILL_VERSION = import("DRILL_VERSION");
    static immutable(string) BUILD_TIME = __TIMESTAMP__;
    static immutable(string) GITHUB_URL = "https://github.com/yatima1460/Drill";
    static immutable(string) WEBSITE_URL = "https://www.drill.santamorena.me";
    static immutable(string) AUTHOR_URL = "https://www.linkedin.com/in/yatima1460/";
    static immutable(string) AUTHOR_NAME = "Federico Santamorena";


public:



    /**
    Initializes a new Drill search engine
    */
    this(immutable(string) assetsDirectory)
    {
        import core.stdc.signal : signal;
        //signal(10, null); 
        Logger.logDebug("DrillAPI " ~ DRILL_VERSION);
        Logger.logDebug("Mount points found: "~to!string(getMountPoints()));
        auto blockListsFullPath = buildPath(assetsDirectory,"BlockLists");

        Logger.logDebug("Assets Directory: " ~ assetsDirectory);
        Logger.logDebug("blockListsFullPath: " ~ blockListsFullPath);

        try
        {
            BLOCK_LIST = cast(immutable(string[]))readListFiles(blockListsFullPath);
        }
        catch (FileException fe)
        {
            Logger.logError(fe.toString());
            Logger.logError("Error when trying to load block lists, will default to an empty list");
        }
        try
        {
            PRIORITY_LIST = cast(immutable(string[]))readListFiles(buildPath(assetsDirectory,"PriorityLists"));
            this.PRIORITY_LIST_REGEX = PRIORITY_LIST[].map!(x => regex(x)).array;
        }
        catch (FileException fe)
        {
            Logger.logError(fe.toString());
            Logger.logError("Error when trying to read priority lists, will default to an empty list");
        }
    }

    // void startCrawler(immutable(string) mountpoint, immutable(string) search,
    //         void delegate(immutable(FileInfo) result) resultFound)
    // {

    // }

    // void startCrawler(immutable(string) mountpoint, immutable(string) search,
    //         void delegate(immutable(FileInfo) result) resultFound)
    // {

    // }

    /**
    Starts the crawling, every crawler will filter on its own.
    Use the resultFound callback as an event to know when a crawler finds a new result.
    You can call this without stopping the crawling, the old crawlers will get stopped automatically.
    If a crawling is already in progress the current one will get stopped asynchronously and a new one will start.

    Params:
        search = the search string, case insensitive, every word (split by space) will be searched in the file name
        resultFound = the delegate that will be called when a crawler will find a new result
    */
    void startCrawling(immutable(string) search, void function(immutable(FileInfo) result, void* userObject) resultFound, void* userObj)
    {
        if (userObj is null)
            throw new Exception("it does not make sense for a userObject to be null");
        // stop previous crawlers
        this.stopCrawlingSync();

        foreach (immutable(string) mountpoint; getMountPoints())
        {
            Crawler crawler = new Crawler(mountpoint, this.BLOCK_LIST, this.PRIORITY_LIST_REGEX, resultFound, search,userObj);
            if (singlethread)
                crawler.run();
            else
                crawler.start();
            this.threads.insertBack(crawler);
        }
    }


    void setSinglethread(bool flag)
    {
        this.singlethread = flag;
    }

    /*
    Notifies the crawlers to stop and clears the crawlers array stored inside DrillAPI
    This function is non-blocking.
    If no crawling is currently underway this function will do nothing.
    */
    void stopCrawlingAsync()
    {
        foreach (Crawler crawler; this.threads)
            crawler.stopAsync();
        this.threads.clear(); // TODO: if nothing has a reference to a thread does the thread get GC-ed?
    }

    /**
    This function stops all the crawlers and will return only when all of them are stopped
    */
    void stopCrawlingSync()
    {
        foreach (Crawler crawler; this.threads)
            crawler.stopAsync();
        waitForCrawlers();
    }

    /**
    This function will return only when all crawlers finished their jobs or were stopped
    This function does not stop the crawlers!!!
    */
    void waitForCrawlers()
    {
        Logger.logInfo("Waiting for "~to!string(getActiveCrawlersCount())~" crawlers to stop");
        foreach (Crawler crawler; this.threads)
        {
            Logger.logInfo("Waiting for crawler "~to!string(crawler)~" to stop");
            import core.thread : ThreadException;
            try
            {
                crawler.join();
                Logger.logInfo("Crawler "~to!string(crawler)~" stopped");
            }
            catch(ThreadException e)
            {
                Logger.logError("Thread "~crawler.toString()~" crashed when joining");
                Logger.logError(e.msg);
            }
            
        }
        Logger.logInfo("All crawlers stopped.");
    }

import ApplicationInfo : ApplicationInfo;

    static @system ApplicationInfo[] getApplicationsInfo()
    {
        version(linux)
        {
            ApplicationInfo[] applications;
            string[] desktopFiles = getDesktopFilesList();
            foreach (desktopFile; desktopFiles)
            {
                // ApplicationInfo ai;
                 import Utils : readDesktopFile;
                // ai.name = getDesktopFileNameValue(desktopFile);
                // ai.desktopFileFullPath = desktopFile;

                // ai.exec = getDesktopFileExecValue(desktopFile);

                applications ~= readDesktopFile(desktopFile);
            }
            return applications;
        }
        else
        {
            return [];
        }
    }
    //alias getApplicationsInfo = memoize!_getApplicationsInfo;


    static @system string[] getDesktopFilesList()
    {
        version(linux)
        {
            immutable auto ls = executeShell("ls /usr/share/applications/*.desktop | grep -v _");
            if (ls.status == 0)
            {
                // TODO: move to init
                // Logger.logError("Can't retrieve applications, will return an empty list");
                return ls.output.split("\n");
            }
        }
        return [];
    }
    //alias getApplicationsList = memoize!_getDesktopFilesList;

    /**
    Returns the mount points of the current system

    Returns: immutable array of full paths

    It's not assured that every mount point is a physical disk
    */


    static @system string[] getMountPoints()
    {
        version (linux)
        {
            // df catches network mounted drives like NFS
            // so don't use lsblk here
            immutable auto ls = executeShell("df -h --output=target");
            if (ls.status != 0)
            {
                Logger.logError("Can't retrieve mount points, will just scan '/'");
                return ["/"];
            }
            auto result = array(ls.output.split("\n").filter!(x => canFind(x, "/"))).idup;
            //debug{logConsole("Mount points found: "~to!string(result));}
            return cast(string[])result;
        }

        version (OSX)
        {
            immutable auto ls = executeShell("df -h");
            if (ls.status != 0)
            {
                Logger.logError("Can't retrieve mount points, will just scan '/'");
                return ["/"];
            }
            immutable auto startColumn = indexOf(ls.output.split("\n")[0], 'M');
            auto result = array(ls.output.split("\n").filter!(x => x.length > startColumn).map!(x => x[startColumn .. $]).filter!(x => canFind(x, "/"))).idup;
            //debug{logConsole("Mount points found: "~result);}
            return cast(string[])result;
        }

        version (Windows)
        {
            immutable auto ls = executeShell("wmic logicaldisk get caption");
            if (ls.status != 0)
            {
                Logger.logError("Can't retrieve mount points, will just scan 'C:'");
                return ["C:"];
            }

            auto result = array(map!(x => x[0 .. 2])(ls.output.split("\n").filter!(x => canFind(x, ":")))).idup;
            //debug{logConsole("Mount points found: "~result);}
            return cast(string[])result;
        }
    }
    import std.functional : memoize;
    //alias getMountPoints = memoize!_getMountPoints;

    /**
    A crawler is active when it's scanning something.
    If a crawler cleanly finished its job it's not considered active.
    If a crawler crashes (should never happen) it's not considered active.
    Minimum: 0
    Maximum: length of total number of mountpoints unless the user started the crawlers manually

    Returns: number of crawlers active

    */
    const @nogc @safe immutable(uint) getActiveCrawlersCount()
    {
        int active = 0;
        for (int i = 0; i < threads.length; i++)
        {
            if (threads[i].isCrawling())
                active++;
        }
        return active;
    }


}
