
version (Renamer) void main()
{
    import std.stdio;
    import std.path;
    import std.file;

 foreach(string filename; dirEntries(".", "*.wav", SpanMode.shallow))
 {
    string new_filename = filename[$-5.. $];
    copy(filename, new_filename);
    remove(filename);
 }
} 