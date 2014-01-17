function! Person(name)
  let p = {}
  let p.name = a:name
  func p.greet(another)
    return "hello, " . a:another.name
  endfunc
  return p
endfunction

function! ExcitedPerson(name)
  let p = Person(a:name)
  func! p.greet(another)
    return "Hot diggity, " . a:another.name . '!'
  endfunc
  return p
endfunction

function! Child(name)
  let p = ExcitedPerson(a:name)
  let p.parent_greet = p.greet
  func! p.greet(another)
    return call(self.parent_greet, [a:another], self) . ". Where's my present?!"
  endfunc
  return p
endfunction

let a = Person('Alice')
let b = ExcitedPerson('Bob')
let c = Child('Charlie')

for p in [b, c]
  echo p.greet(a)
  echo a.greet(p)
  unlet p
endfor
