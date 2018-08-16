type
    Elems{.unchecked.}[T] = array[0..0, T]
    List*[T] = object
      len: Natural
      elms: ptr Elems[T]
  
proc allocList*[T](len: Natural): List[T] =
    result = List[T](len: len, elms: cast[ptr Elems[T]](alloc(len*sizeof(T))))

proc `=destroy`(list: var List) =
    if list.elms != nil: dealloc list.elms:
        echo "List destroyed"

proc `[]`*[T](list: var List[T]; i: Natural): var T =
    list.elms[][i.int]

proc `[]=`*[T](list: List[T]; i: Natural, x: T) =
    list.elms[][i] = x