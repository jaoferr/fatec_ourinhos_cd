class TreeNode:
    
    def __init__(self, x):
        self.value = x
        self.left = None
        self.right = None

def search_tree(tree, value):
    root_node = tree.value
    if value < root_node:
        node = tree.left
    else:
        node = tree.right
    
    if not node:
        return root_node

    found_value = search_tree(node, value)
    return min((root_node, found_value), key=lambda x: abs(value - x))


if __name__ == '__main__':
    tree = TreeNode(5)
    tree.left = TreeNode(10)
    tree.left.left = TreeNode(4)
    tree.left.right = TreeNode(9)
    tree.left.right.left = TreeNode(12)

    tree.right = TreeNode(6)
    tree.right.right = TreeNode(3)
    tree.right.left = TreeNode(8)
    
    print(search_tree(tree, 12))
