def merge($a; $b):
  if ($a|type) == "object" and ($b|type) == "object" then
    reduce (($a + $b) | keys_unsorted[]) as $k ({};
      .[$k] = if ($a|has($k)) and ($b|has($k)) then merge($a[$k]; $b[$k])
              elif ($a|has($k)) then $a[$k] else $b[$k] end)
  elif ($a|type) == "array" and ($b|type) == "array" then $a + ($b - $a)
  else $b end;
merge(.[0]; .[1])
