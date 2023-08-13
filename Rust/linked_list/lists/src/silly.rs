// silly1.rs
pub struct Stack<T> {
    head: Link<T>,
}

type Link<T> = Option<Box<Node<T>>>;

struct Node<T> {
    elem: T,
    next: Link<T>,
}

impl<T> Stack<T> {
    pub fn new() -> Self {
        Stack { head: None }
    }

    pub fn push(&mut self, elem: T) {
        let new_node = Box::new(Node {
            elem: elem,
            next: None,
        });

        self.push_node(new_node);
    }

    fn push_node(&mut self, mut node: Box<Node<T>>) {
        node.next = self.head.take();
        self.head = Some(node);
    }

    pub fn pop(&mut self) -> Option<T> {
        self.pop_node().map(|node| { node.elem })
    }

    fn pop_node(&mut self) -> Option<Box<Node<T>>> {
        self.head.take().map(|mut node| {
            self.head = node.next.take();
            node
        })
    }

    pub fn peek(&self) -> Option<&T> {
        self.head.as_ref().map(|node| { &node.elem })
    }

    pub fn peek_mut(&mut self) -> Option<&mut T> {
        self.head.as_mut().map(|node| { &mut node.elem })
    }
}

impl<T> Drop for Stack<T> {
    fn drop(&mut self) {
        let mut cur_link = self.head.take();
        while let Some(mut boxed_node) = cur_link {
            cur_link = boxed_node.next.take();
        }
    }
}

pub struct List<T> {
    left: Stack<T>,
    right: Stack<T>,
}

impl<T> List<T> {
    fn new() -> Self {
        List { left: Stack::new(), right: Stack::new() }
    }

    pub fn push_left(&mut self, elem: T) {
        self.left.push(elem)
    }

    pub fn push_right(&mut self, elem: T) {
        self.right.push(elem)
    }

    pub fn pop_left(&mut self) -> Option<T> {
        self.left.pop()
    }

    pub fn pop_right(&mut self) -> Option<T> {
        self.right.pop()
    }

    pub fn peek_left(&self) -> Option<&T> {
        self.left.peek()
    }

    pub fn peek_right(&self) -> Option<&T> {
        self.right.peek()
    }

    pub fn peek_left_mut(&mut self) -> Option<&mut T> {
        self.left.peek_mut()
    }

    pub fn peek_right_mut(&mut self) -> Option<&mut T> {
        self.right.peek_mut()
    }

    pub fn go_left(&mut self) -> bool {
        self.left
            .pop_node()
            .map(|node| {
                self.right.push_node(node);
            })
            .is_some()
    }

    pub fn go_right(&mut self) -> bool {
        self.right
            .pop_node()
            .map(|node| {
                self.left.push_node(node);
            })
            .is_some()
    }
}
