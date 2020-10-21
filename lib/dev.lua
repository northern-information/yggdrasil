screen.ping()

dev = {}

function dev:scene(i)
  if i == 1 then
    page:select(1)
  elseif i == 2 then
    page:select(2)
  else
    print("dev scene else")
  end
end

return dev