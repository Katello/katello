# Annotated Requests

## Purpose
To create documentation for our interactions with pulp and candlepin across different workflows.  This allows the pulp and candlepin team to better understand how Katello is utilizing their respective service.

## Components:

1. Scenario test file: ./test/scenarios/scenario_test.rb 
  * Currently houses all scenario tests.  Uses vcr to record reqeusts.
2. Scenario VCR cassettes: ./test/fixtures/vcr_cassettes/scenarios/*.yml
3. Scenario annotations: ./test/scenarios/annotations/*.yaml
  * This provides options for matching a particular vcr request as well as a description of the request. 
4. Scenario Rake tasks: ./lib/katello/tasks/annotate_scenarios.rake. Provides two rake tasks
  * rake katello:find_unannotated_requests
    * finds requests that are not annotated and suggests annotation entries
  * rake katello:create_annotated_output
    * creates the annotated request documentation
    
## Adding a new workflow

1. Add a test in ./test/scenarios/scenario_test.rb 
2. Delete the existing cassettes and re-record:
```bash
rake test:katello:test:live_scenarios
```
3. Create a new scenario file: ./test/scenarios/annotations/my_workflow.yaml with contents:
```yaml
name: Performing Action XYZ
cassette: cassette_name.yml
annotations: []
```
Run the rake task to find unannotated requests:
```
rake katello:find_unannotated_requests
```
Example output
```
Performing Action XYZ
Unmatched Annotations:
Unmatched requests:
---
- method: post
  path: "/some/path"
  title: 
  description: 
```
Simply copy and paste that into your annotation yaml file.  Edit, adding a description and title.  

Run the rake task to generate documentation:

```
rake katello:create_annotated_output
```


## Matching requests

The default matching request matching uses 'method' and 'path', but sometimes path is not enough.  For example, take a pulp task request:

`GET /pulp/api/v2/tasks/45edd69c-479f-49ba-8a05-4218f8e4ab8b/`

the task id is generated at run time and so its impossible to match the path exactly.  Or take the following request:

`GET /pulp/api/v2/repositories/scenario_test/search/units/`

This could be a unit search for rpms, or errata, or any unit type.  We need to do some matching with the body to correctly match the request.


#### starts_with

`starts_with: '/pulp/api/v2/tasks/'`

This will match any request that starts with the specified string.  However this will only be matched for one request.  So if you have two requests '/foo/bar/1' and '/foo/bar/2', and a matcher `starts_with: '/foo/bar'`, only one of these requests would be matched.  However a second entry of `starts_with: '/foo/bar'` would match the second request.

#### request_body

`request_body: "rpm"`

Only matches requests who's request body contains the specified string.  This helps when matching requests that may be made in different orders, but contain the same path and method (with a different body)



