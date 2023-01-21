package main

import (
	"encoding/json"
	"fmt"
	"reflect"
)

func main() {
	var input map[string]interface{} = make(map[string]interface{})

	err := json.Unmarshal([]byte(`{"x":{"y":{"z":"a"}}}`), &input)
	if err != nil {
		panic(err)
	}

	var value = GetValue(input, "a")

	fmt.Printf("Value is: %v\n", value)
}

func GetValue(object map[string]interface{}, key string) interface{} {
	var value interface{} = object[key]
	if value != nil {
		return value
	}

	for k, v := range object {
		if reflect.TypeOf(object[k]).Kind() == reflect.Map {
			value = GetValue(v.(map[string]interface{}), key)
		}

		if value != nil {
			return value
		}
	}

	return nil
}
