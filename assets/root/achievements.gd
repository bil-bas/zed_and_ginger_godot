extends Node


const DEFINITIONS = {
    "WOKE_UP": {
        "stat": "STARTED_APP",
        "required": 1,
    },
    "EVER_COMPLETED_LEVEL_1": {
        "stat": "COMPLETED_LEVEL_1",
        "required": 1,
        "unlocks": ["LEVEL_2"]
    },
    "EVER_COMPLETED_LEVEL_2": {
        "stat": "COMPLETED_LEVEL_2",
        "required": 1,
        "unlocks": ["LEVEL_3"],
    },
    "LONG_WALK_1": {
        "stat": "METRES_WALKED",
        "required": 100
    },
    "LONG_WALK_2": {
        "stat": "METRES_WALKED",
        "required": 1000
    },
    "LONG_WALK_3": {
        "stat": "METRES_WALKED",
        "required": 10000
    },
    "DIED_1": {
        "stat": "DEATHS",
        "required": 10
    },
    "DIED_2": {
        "stat": "DEATHS",
        "required": 100
    },
    "DIED_3": {
        "stat": "DEATHS",
        "required": 1000
    },
    "BURNT_TO_DEATH_1": {
        "stat": "BURNT",
        "required": 10
    },
    "EATEN_TO_DEATH_1": {
        "stat": "EATEN",
        "required": 10
    },
    "STRANGLED_TO_DEATH_1": {
        "stat": "STRANGLED",
        "required": 10
    },
    "EXPLODED_TO_DEATH_1": {
        "stat": "EXPLODED",
        "required": 10
    },
    "ELECTROCUTED_TO_DEATH_1": {
        "stat": "ELECTROCUTED",
        "required": 10
    },
    "FLATTENED_TO_DEATH_1": {
        "stat": "FLATTENED",
        "required": 10
    },
    "JUMPER_1": {
        "stat": "JUMPS",
        "required": 100
    }
}


const NAMES = [
    "WOKE_UP",
    "EVER_COMPLETED_LEVEL_1",
    "EVER_COMPLETED_LEVEL_2",
    "LONG_WALK_1",
    "LONG_WALK_2",
    "LONG_WALK_3",
    "DIED_1",
    "DIED_2",
    "DIED_3",
    "BURNED_TO_DEATH_1",
    "EATEN_TO_DEATH_1",
    "STRANGLED_TO_DEATH_1",
    "EXPLODED_TO_DEATH_1",
    "ELECTROCUTED_TO_DEATH_1",
    "FLATTENED_TO_DEATH_1",
    "JUMPER_1"
]


# Achievements in a local (encrypted file), to save using an external system
class LocalAchievements:
    const FILENAME = "user://achievements.dat"
    var statistics
    var achievements
    var utilities
    var unlocks
    var notify

    func _init(utilities, notify):
        self.utilities = utilities
        self.notify = notify

        # Load or create data.
        if File.new().file_exists(FILENAME):
            _restore()
        else:
            clear()

        # Add defaults (in case they've been added since we saved).
        for name in DEFINITIONS:
            var definition = DEFINITIONS[name]
            var stat = definition["stat"]
            if not stat in statistics:
                statistics[stat] = 0

        increment_stat("STARTED_APP")

        _check()
        save()

        print("stats: ", var2str(statistics))
        print("achievements: ", var2str(achievements))
        print("unlocks: ", var2str(unlocks))

    func increment_stat(name, value=1):
        statistics[name] += value
        _check()

    func save():
        var data = {
            "statistics": statistics,
            "achievements": achievements,
            "unlocks": unlocks
        }
        utilities.save_encrypted(FILENAME, data)

    func clear():
        statistics = {}
        achievements = {}
        unlocks = []

    func has_unlocked(name):
        return (name in unlocks)

    func _restore():
        var data = utilities.load_encrypted(FILENAME)
        statistics = data["statistics"]
        achievements = data["achievements"]
        unlocks = data["unlocks"]

    func _check():
        """Check if any achievements have been completed"""

        for name in DEFINITIONS:
            if name in achievements:
                continue

            var definition = DEFINITIONS[name]
            var stat = definition["stat"]
            if statistics[stat] >= definition["required"]:
                var date = OS.get_date()
                var time = OS.get_time()
                var timestamp = "%d-%02d-%02d %02d:%02d" % [date["year"], date["month"], date["day"], time["hour"], time["minute"]]
                achievements[name] = timestamp

                if "unlocks" in definition:
                    for unlock in definition["unlocks"]:
                        if not unlock in unlocks:
                            unlocks.append(unlock)

                var title = "%s_TITLE" % name
                var description = "%s_DESCRIPTION" % name
                notify.call_func(title, description)

var achievements

func _ready():
    # TODO: select based on what is available.
    var Achievements = LocalAchievements

    var utilities = get_node(@"/root/utilities")
    achievements = Achievements.new(utilities, funcref(self, "_notify"))

func get_stat(name):
    return achievements.get_stat(name)

func increment_stat(name, value=1):
    achievements.increment_stat(name, value)

func has_unlocked(name):
    return achievements.has_unlocked(name)

func clear():
    achievements.clear()

func save():
    achievements.save()

func _notify(title, description):
    var notification = get_node(@"/root/Root/Overlay/AchievementNotification")
    var icon = notification.get_node(@"VBox/HBox/Icon")
    var _title = notification.get_node(@"VBox/HBox/Name")
    var _description = notification.get_node(@"VBox/Description")
    var animation = notification.get_node(@"Animation")

    # TODO: Deal with the notification already being shown by another achievement.
    _title.set_text(title)
    _description.set_text(description)
    animation.play("show")
