source(g_currentModDirectory .. "Gui.lua")

TaskManager = {}

function TaskManager:load(mission)
    print("TaskManager: loading...")
    self.gui = TaskManagerGui.new(self)
    g_input:addKeyListener(self)
end

function TaskManager:delete()
    print("TaskManager: deleting...")
    g_input:removeKeyListener(self)
end

function TaskManager:keyEvent(unicode, sym, modifier, isDown)
    if isDown then
        if sym == Input.KEY_t and Input.isShiftPressed() == false and Input.isCtrlPressed() == false and Input.isAltPressed() == true then
            if self.gui.isOpen then
                self.gui:close()
            else
                self.gui:open()
            end
        end
    end
end

addModEventListener(TaskManager)
