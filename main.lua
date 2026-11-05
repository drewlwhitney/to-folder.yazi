-- TODO: make it possible to undo this operation by sending the files to the trash.
-- Requires a send-to-trash API and integration with `just-kidding.yazi`

---@class State
---@field prompt boolean

---@class Options
---@field prompt boolean?

---Show an error message.
---@param message string
local function notify_error(message)
    ya.notify({
        title = "Error converting to folders",
        content = message,
        timeout = 3.0,
        level = "error",
    })
end

---Format a list of paths (`File`s) as a list of `Line`s.
---@param files File[]
---@return ui.Line[]
local function format_file_list(files)
    local lines = {}
    for _, file in ipairs(files) do
        lines[#lines + 1] = ui.Line(tostring(file.url)):align(ui.Align.LEFT)
    end
    return lines
end

---Prompt the user whether they want to permanently delete the selected files
---and replace them with folders.
---@param files File[]
local function prompt(files)
    return ya.confirm({
        pos = { "center", w = 70, h = 20 },
        title = "Replace " .. #files .. " with folders? This cannot be undone",
        body = ui.Text(format_file_list(files)),
    })
end

-- get the `File`s of the currently selected/hovered files
local get_selected = ya.sync(function(_)
    local cx_selected = cx.active.selected
    if #cx_selected > 0 then
        local selected = {}
        for _, file in pairs(cx_selected) do
            selected[#selected + 1] = file
        end
        return selected
    end
    -- this shouldn't ever be nil at this point
    local hovered = cx.active.current.hovered
    return { hovered }
end)

--get the `prompt` config setting
local should_prompt = ya.sync(function(state)
    return state.prompt
end)

---Setup.
---@param state State
---@param opts Options?
local function setup(state, opts)
    state.prompt = (opts or {}).prompt or true
end

return {
    setup = setup,
    entry = function(_self, _job)
        local selected = get_selected()

        -- make sure it's only files, not folders/links
        for _, file in ipairs(selected) do
            local cha = file.cha
            if cha.is_dir then
                notify_error("Cannot operate on folders")
                return
            elseif cha.is_link then
                notify_error("Cannot operate on symlinks")
                return
            end
        end

        if should_prompt() and not prompt(selected) then
            return
        end

        for _, file in ipairs(selected) do
            local url = file.url
            -- remove the file
            local _, remove_err = fs.remove("file", url)
            if remove_err ~= nil then
                notify_error(tostring(remove_err))
                return
            end

            -- create the new directory
            fs.create("dir", url)
            -- yay done
        end
    end,
}
