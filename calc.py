import sys
import javalang

def immutable(tree):
  tlist = [v for v in tree]
  fields = tlist[0][1].filter(javalang.tree.FieldDeclaration)
  immutable = True
  for path, node in fields:
    if not 'final' in node.modifiers:
      immutable = False
  return immutable

def ncss(tree):
  metric = 0
  for path, node in tree:
    node_type = str(type(node))
    if 'Statement' in node_type:
      metric += 1
    elif 'VariableDeclarator' == node_type:
      metric += 1
    elif 'Assignment' == node_type:
      metric += 1
    elif 'Declaration' in node_type and 'LocalVariableDeclaration' not in node_type and 'PackageDeclaration' not in node_type:
      metric += 1
  return metric


with open(sys.argv[1], encoding='utf-8') as f:
  raw = javalang.parse.parse(f.read())
  tree = raw.filter(javalang.tree.ClassDeclaration)
  print(str(ncss(raw)) + ',' + ('yes' if immutable(tree) else 'no'))
