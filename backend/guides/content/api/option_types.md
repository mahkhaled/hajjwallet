---
title: Option Types
description: Use the Spree Commerce storefront API to access OptionType data.
---

## Index

Retrieve a list of option types by making this request:

``` text
GET /api/v1/option_types
```

### Parameters

ids
: A comma-separated list of option type ids. Specifying this parameter will display the respective option types.

### Response

<%= headers 200 %>
<%= json(:option_type){ |h| [h] } %>

## Search

To search for a specific option type, make a request like this:

```text
GET /api/v1/option_types?q[name_cont]=color
```

The searching API is provided through the Ransack gem which Spree depends on. The `name_cont` here is called a predicate, and you can learn more about them by reading about [Predicates on the Ransack wiki](https://github.com/ernie/ransack/wiki/Basic-Searching).

### Response

<%= headers 200 %>
<%= json(:option_type){ |h| [h] } %>

### Sorting results

Results can be returned in a specific order by specifying which field to sort by when making a request.

```text
GET /api/v1/option_types?q[s]=name%20asc
```

## Show

Retrieve details about a particular option type:

```text
GET /api/v1/option_types/1
```

### Response

<%= headers 200 %>
<%= json(:option_type) %>

## New

You can learn about the potential attributes (required and non-required) for a option type by making this request:

```text
GET /api/v1/option_types/new
```

### Response

<%= headers 200 %>
<%= json \
  "attributes": [
      "id", "name", "presentation", "position"
  ],
  "required_attributes": [
      "name", "presentation"
  ]
%>

## Create

<%= admin_only %>

To create a new option type through the API, make this request with the necessary parameters:

```text
POST /api/v1/option_types
```

For instance, a request to create a new option type called "tshirt-category" with a presentation value of "Category" would look like this:

```text
POST api/v1/option_types/?option_type[name]=tshirt-category&option_type[presentation]=Category
```

### Successful Response

<%= headers 201 %>

### Failed Response

<%= headers 422 %>
<%= json \
  error: "Invalid resource. Please fix errors and try again.",
  errors: {
    "name": ["can't be blank"],
     "presentation": ["can't be blank"]
  }
%>

## Update

<%= admin_only %>

To update a option type's details, make this request with the necessary parameters:

```text
PUT /api/v1/option_types/1
```

For instance, to update a option types's name, send it through like this:

```text
PUT /api/v1/option_types/3?option_type[name]=t-category
```

### Successful Response

<%= headers 201 %>

### Failed Response

<%= headers 422 %>
<%= json \
  error: "Invalid resource. Please fix errors and try again.",
  errors: {
    name: ["can't be blank"],
    presentation: ["can't be blank"]
  }
%>


## Delete

<%= admin_only %>

To delete a option type, make this request:

```text
DELETE /api/v1/option_types/1
```

This request removes a option type from database.

<%= headers 204 %>
