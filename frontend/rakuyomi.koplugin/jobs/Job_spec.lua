---@diagnostic disable: undefined-global, undefined-field

-- `Job` reaches the backend through the `Backend` module; stub it through
-- `package.preload` so the spec does not pull in KOReader.
package.preload['ffi/util'] = function()
  return { sleep = function() end }
end
package.preload['Backend'] = function()
  return {
    requestJobCancellation = function(id)
      if id == nil then
        return { type = 'ERROR', message = 'no job id' }
      end

      if id == 'failing' then
        return { type = 'ERROR', message = 'backend refused' }
      end

      return { type = 'SUCCESS' }
    end,
  }
end

local Job = require('jobs/Job')

describe('Job:requestCancellation', function()
  it('should return false without calling the backend when the job was never started', function()
    local job = Job:extend()
    job.job_id = nil

    assert.is_false(job:requestCancellation())
  end)

  it('should return true when the backend accepts the cancellation', function()
    local job = Job:extend()
    job.job_id = 'running'

    assert.is_true(job:requestCancellation())
  end)

  it('should return false when the backend refuses the cancellation', function()
    local job = Job:extend()
    job.job_id = 'failing'

    assert.is_false(job:requestCancellation())
  end)
end)
