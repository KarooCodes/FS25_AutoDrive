ADCPTaskManager = {}
ADCPTaskManager.STATES = {
    IDLE = "IDLE",
    DRIVING_TO_DESTINATION = "DRIVING_TO_DESTINATION",
    AT_DESTINATION = "AT_DESTINATION",
    RUNNING_CP_COURSE = "RUNNING_CP_COURSE",
    CP_COURSE_FINISHED = "CP_COURSE_FINISHED",
    FINISHED = "FINISHED"
}

function ADCPTaskManager.prerequisites(specializations)
    return true
end

function ADCPTaskManager.new(mt, ...)
    local self = {}
    setmetatable(self, {__index = ADCPTaskManager})

    self.adcpTaskList = {}
    self.adcpCurrentTask = 0
    self.adcpIsRunning = false
    self.adcpState = ADCPTaskManager.STATES.IDLE
    self.vehicle = mt.source

    return self
end

function ADCPTaskManager:load(xmlFile, key)
    -- We will add logic to load saved task lists here later
end

function ADCPTaskManager:delete()
    -- Cleanup logic here
end

function ADCPTaskManager:mouseEvent(posX, posY, isDown, isUp, button)
    -- Handle mouse events if needed for the GUI
end

function ADCPTaskManager:keyEvent(unicode, sym, modifier, isDown)
    -- Handle key events if needed for the GUI
end

function ADCPTaskManager:update(dt)
    if not self.adcpIsRunning then
        return
    end

    if self.adcpState == ADCPTaskManager.STATES.RUNNING_CP_COURSE then
        if self.vehicle and self.vehicle.getIsCpActive and not self.vehicle:getIsCpActive() then
            print("TaskManager: CP course finished.")
            self.adcpState = ADCPTaskManager.STATES.CP_COURSE_FINISHED
            self.adcpCurrentTask = self.adcpCurrentTask + 1
            self:startNextTask()
        end
    end
end

function ADCPTaskManager:draw()
    -- Custom drawing if needed
end

function ADCPTaskManager:setTaskList(taskList)
    self.adcpTaskList = taskList
    self.adcpCurrentTask = 0
    self.adcpIsRunning = false
    self.adcpState = ADCPTaskManager.STATES.IDLE
    print("TaskManager: Task list set on vehicle.")
end

function ADCPTaskManager:toggleTaskRunner()
    self.adcpIsRunning = not self.adcpIsRunning
    if self.adcpIsRunning then
        if #self.adcpTaskList == 0 then
            print("TaskManager: Cannot start, task list is empty.")
            self.adcpIsRunning = false
            return
        end
        print("TaskManager: Starting task runner.")
        self.adcpCurrentTask = 1
        self:startNextTask()
    else
        print("TaskManager: Stopping task runner.")
        self:stopCurrentTask()
    end
end

function ADCPTaskManager:startNextTask()
    if not self.adcpIsRunning then return end

    if self.adcpCurrentTask > #self.adcpTaskList then
        print("TaskManager: All tasks finished.")
        self.adcpIsRunning = false
        self.adcpState = ADCPTaskManager.STATES.FINISHED
        return
    end

    local task = self.adcpTaskList[self.adcpCurrentTask]
    print(string.format("TaskManager: Starting task %d: AD dest %s", self.adcpCurrentTask, task.ad_name))

    self.adcpState = ADCPTaskManager.STATES.DRIVING_TO_DESTINATION
    AutoDrive:StartDriving(self.vehicle, task.ad_id, nil, self, self.onAdArrived)
end

function ADCPTaskManager:onAdArrived()
    if not self.adcpIsRunning then return end

    print("TaskManager: Arrived at AD destination.")
    self.adcpState = ADCPTaskManager.STATES.AT_DESTINATION

    local task = self.adcpTaskList[self.adcpCurrentTask]
    local cp_course_name = task.cp_name

    if self.vehicle == nil or self.vehicle.getCpCourses == nil then
        print("TaskManager: Could not find CP courses on vehicle.")
        self.adcpIsRunning = false
        return
    end

    local courses = self.vehicle:getCpCourses()
    local course_to_run = nil
    if courses then
        for _, course in ipairs(courses) do
            if course.name == cp_course_name then
                course_to_run = course
                break
            end
        end
    end

    if course_to_run then
        print("TaskManager: Starting CP course: " .. cp_course_name)
        self.vehicle:setFieldWorkCourse(course_to_run)
        self.adcpState = ADCPTaskManager.STATES.RUNNING_CP_COURSE
        if not self.vehicle:getIsCpActive() then
            self.vehicle:cpStartStopDriver()
        end
    else
        print("TaskManager: Could not find CP course: " .. cp_course_name)
        self.adcpIsRunning = false
    end
end

function ADCPTaskManager:stopCurrentTask()
    if self.vehicle and self.vehicle.getIsCpActive and self.vehicle:getIsCpActive() then
        self.vehicle:stopCpDriver()
    end
    -- Stopping AD is not directly supported by the API.
    -- The runner will just not proceed to the next step.
    self.adcpState = ADCPTaskManager.STATES.IDLE
end
