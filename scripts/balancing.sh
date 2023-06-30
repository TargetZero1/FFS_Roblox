#!/usr/bin/env bash
# https://github.com/nightcycle/spreadsheet-to-luau
# modifier data
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/WindmillValueData.lua -page 532615803
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/WindmillRechargeData.lua -page 1595369876
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/WrapperRechargeData.lua -page 480745980
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/WrapperMultiplierData.lua -page 1278928281
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/KneaderMultiplierData.lua -page 1511815929
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/KneaderRechargeData.lua -page 964197410
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/OvenRechargeData.lua -page 507150770
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/OvenValueData.lua -page 1099296438
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/RackStorageData.lua -page 798004549
# pet data
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -nospace -o out/Balancing/PetData.lua -page 362628847 -id Id
# reward data
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -page 222283899 -o out/Balancing/RewardData.lua -nospace
# time rewards
spreadsheet-to-luau -sheet 1taJAXwgkGXRGrknzp7LSKUB6l0O3YQoNnyhTEh7KLHE -page 1569981712 -o out/Balancing/TimerRewardData.lua -nospace
# generate sourcemap
sh scripts/sourcemap.sh