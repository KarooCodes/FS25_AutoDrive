TaskManagerGui = {}
TaskManagerGui.GUI_XML_FILE = "gui.xml"
TaskManagerGui.SAVE_FILE = "ADCP_task_list.xml"

function TaskManagerGui.new(base)
    local self = {}
    setmetatable(self, {__index = TaskManagerGui})
    self.base = base
    self.isOpen = false
    self.tasks = {}
    return self
end

function TaskManagerGui:open()
    if self.isOpen then
        return
    end

    local modDir = g_currentModDirectory
    local xmlFile = modDir .. self.GUI_XML_FILE
    g_gui:loadXml(xmlFile, "ui_ADCP_TaskManager", self)
    g_gui:show("ui_ADCP_TaskManager")
    self.isOpen = true
end

function TaskManagerGui:close()
    if not self.isOpen then
        return
    end
    g_gui:hide("ui_ADCP_TaskManager")
    self.isOpen = false
end

function TaskManagerGui:onOpen(guidata)
    -- Buttons
    self.addButton = guidata.addButton
    self.editButton = guidata.editButton
    self.removeButton = guidata.removeButton
    self.saveButton = guidata.saveButton
    self.loadButton = guidata.loadButton
    self.assignButton = guidata.assignButton
    self.startButton = guidata.startButton
    self.closeButton = guidata.closeButton

    -- Dropdowns
    self.adDestinationDropdown = guidata.adDestinationDropdown
    self.cpCourseDropdown = guidata.cpCourseDropdown

    -- Listbox
    self.taskList = guidata.taskList

    -- Add listeners
    g_gui:addInputListener(self.addButton, "onClick", self)
    g_gui:addInputListener(self.removeButton, "onClick", self)
    g_gui:addInputListener(self.saveButton, "onClick", self)
    g_gui:addInputListener(self.loadButton, "onClick", self)
    g_gui:addInputListener(self.assignButton, "onClick", self)
    g_gui:addInputListener(self.startButton, "onClick", self)
    g_gui:addInputListener(self.closeButton, "onClick", self)

    self:populateAdDestinations()
    self:populateCpCourses()
end

function TaskManagerGui:onClose()
    -- Cleanup
end

function TaskManagerGui:onClick(element)
    if element == self.closeButton then
        self:close()
    elseif element == self.addButton then
        self:onAddTask()
    elseif element == self.removeButton then
        self:onRemoveTask()
    elseif element == self.saveButton then
        self:onSaveList()
    elseif element == self.loadButton then
        self:onLoadList()
    elseif element == self.assignButton then
        self:onAssignToVehicle()
    elseif element == self.startButton then
        self:onStartStopRunner()
    end
end

function TaskManagerGui:onAssignToVehicle()
    local vehicle = g_currentMission.controlledVehicle
    if vehicle and vehicle.spec_ADCPTaskManager then
        vehicle.spec_ADCPTaskManager:setTaskList(self.tasks)
        print("TaskManager: Task list assigned to current vehicle.")
    else
        print("TaskManager: Could not assign task list. No vehicle or specialization found.")
    end
end

function TaskManagerGui:onStartStopRunner()
    local vehicle = g_currentMission.controlledVehicle
    if vehicle and vehicle.spec_ADCPTaskManager then
        vehicle.spec_ADCPTaskManager:toggleTaskRunner()
    end
end

function TaskManagerGui:onAddTask()
    local ad_id = self.adDestinationDropdown:getSelectedData()
    local ad_name = self.adDestinationDropdown:getSelectedText()
    local cp_name = self.cpCourseDropdown:getSelectedData()

    if ad_id and cp_name then
        local task = {
            ad_id = ad_id,
            ad_name = ad_name,
            cp_name = cp_name
        }
        table.insert(self.tasks, task)
        self.taskList:add(string.format("AD: %s -> CP: %s", ad_name, cp_name), task)
    else
        print("TaskManager: Please select an AD destination and a CP course.")
    end
end

function TaskManagerGui:onRemoveTask()
    local selectedIndex = self.taskList:getSelectedIndex()
    if selectedIndex > 0 then
        table.remove(self.tasks, selectedIndex)
        self.taskList:remove(selectedIndex)
    end
end

function TaskManagerGui:onSaveList()
    local xmlFile = createXMLFile("tasks")
    for i, task in ipairs(self.tasks) do
        local key = string.format("tasks.task(%d)", i-1)
        setXMLString(xmlFile, key .. "#ad_id", task.ad_id)
        setXMLString(xmlFile, key .. "#cp_name", task.cp_name)
    end

    local path = g_currentModUserStoragePath .. self.SAVE_FILE
    if saveXMLFile(xmlFile, path) then
        print("TaskManager: Task list saved to " .. path)
    else
        print("TaskManager: Error saving task list.")
    end
    delete(xmlFile)
end

function TaskManagerGui:onLoadList()
    local path = g_currentModUserStoragePath .. self.SAVE_FILE
    local xmlFile = loadXMLFile("tasks", path)
    if xmlFile == 0 then
        print("TaskManager: No task list file found.")
        return
    end

    self.tasks = {}
    self.taskList:clear()

    local i = 0
    while true do
        local key = string.format("tasks.task(%d)", i)
        if not hasXMLProperty(xmlFile, key) then
            break
        end
        local ad_id_str = getXMLString(xmlFile, key .. "#ad_id")
        local ad_id = tonumber(ad_id_str)
        local cp_name = getXMLString(xmlFile, key .. "#cp_name")

        local ad_name = "Unknown Destination"
        if g_AutoDrive and AutoDrive.GetAvailableDestinations then
            local destinations = AutoDrive:GetAvailableDestinations()
            if destinations and destinations[ad_id] then
                ad_name = destinations[ad_id].name
            end
        end

        local task = {
            ad_id = ad_id,
            ad_name = ad_name,
            cp_name = cp_name
        }
        table.insert(self.tasks, task)
        self.taskList:add(string.format("AD: %s -> CP: %s", ad_name, cp_name), task)
        i = i + 1
    end
    delete(xmlFile)
    print("TaskManager: Task list loaded.")
end


function TaskManagerGui:populateAdDestinations()
    if g_AutoDrive == nil or self.adDestinationDropdown == nil then
        print("TaskManager: AutoDrive not found or dropdown not found.")
        return
    end

    self.adDestinationDropdown:clear()
    local destinations = AutoDrive:GetAvailableDestinations()
    if destinations ~= nil then
        for id, dest in pairs(destinations) do
            self.adDestinationDropdown:add(dest.name, id)
        end
    end
end

function TaskManagerGui:populateCpCourses()
    if g_Courseplay == nil or _G.CpUtil == nil or self.cpCourseDropdown == nil then
        print("TaskManager: CoursePlay not found or dropdown not found.")
        return
    end

    self.cpCourseDropdown:clear()
    local vehicle = CpUtil.getCurrentVehicle()
    if vehicle ~= nil and vehicle.getCpCourses ~= nil then
        local courses = vehicle:getCpCourses()
        if courses ~= nil then
            for i, course in ipairs(courses) do
                if course.name then
                    self.cpCourseDropdown:add(course.name, course.name) -- Using name as data for now
                end
            end
        end
    else
        print("TaskManager: Could not get current vehicle or vehicle does not have CoursePlay.")
    end
end
