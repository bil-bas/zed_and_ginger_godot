extends Node

func load_json(name):
    var json = File.new()
    assert(json.file_exists(name))
    json.open(name, File.READ)
    var data = {}
    var status = data.parse_json(json.get_as_text())
    json.close()
    assert(status == OK)

    return data


func save_json(name, data):
    var json = File.new()
    json.open(name, File.WRITE)
    json.store_string(data.to_json())
    json.close()


func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files
