# Graphs

*Note: If you do not see any graph images please generate them, see bottom of this page.*

## Models brief

<div style="overflow: scroll; width: 100%;">
  <img style="height: 800px;" src="graphs/models_brief.svg" >
</div>

## Models complete

<div style="overflow: scroll; width: 100%;">
  <img style="height: 800px;" src="graphs/models_complete.svg" >
</div>

## Controllers brief

<div style="overflow: scroll; width: 100%;">
  <img style="height: 800px;" src="graphs/controllers_brief.svg" >
</div>

## Controllers complete

<div style="overflow: scroll; width: 100%;">
  <img style="height: 800px;" src="graphs/controllers_complete.svg" >
</div>

## How to generate and update these graphs

- enable `railroady` gem in `bundler.d/development.rb`
- generate svg graphs

      !!!txt
      bundle exec rake diagram:all

- move them to graphs folder

      !!!txt
      mv -f doc/*.svg doc/graphs
