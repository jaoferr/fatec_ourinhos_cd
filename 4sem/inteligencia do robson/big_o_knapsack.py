import big_o
import random

from numpy.core.fromnumeric import size

class ItemValue:
 
    """Item Value DataClass"""
 
    def __init__(self, wt, val, ind):
        self.wt = wt
        self.val = val
        self.ind = ind
        self.cost = val // wt
 
    def __lt__(self, other):
        return self.cost < other.cost
 
# Greedy Approach
 
 
class FractionalKnapSack:
 
    """Time Complexity O(n log n)"""
    @staticmethod
    def getMaxValue(wt, val, capacity):
        """function to get maximum value """
        iVal = []
        for i in range(len(wt)):
            iVal.append(ItemValue(wt[i], val[i], i))
 
        # sorting items by value
        iVal.sort(reverse=True)
 
        totalValue = 0
        for i in iVal:
            curWt = int(i.wt)
            curVal = int(i.val)
            if capacity - curWt >= 0:
                capacity -= curWt
                totalValue += curVal
            else:
                fraction = capacity / curWt
                totalValue += curVal * fraction
                capacity = int(capacity - (curWt * fraction))
                break
        return totalValue
 
 
def run_big_o_knapsack(n):
    val = random.sample(range(10, 1000), n)
    wt = random.sample(range(10, 1000), n)
    W = 50
    n = len(val)
    return FractionalKnapSack.getMaxValue(wt, val, W)


# Driver Code
if __name__ == "__main__":
    wt = [10, 40, 20, 30]
    val = [60, 40, 100, 120]
    capacity = 50
 
    # Function call
    maxValue = FractionalKnapSack.getMaxValue(wt, val, capacity)
    print("Maximum value in Knapsack =", maxValue)

    best = big_o.big_o(run_big_o_knapsack, big_o.datagen.n_, n_repeats=100, min_n=200, max_n=800)
    print(f'Big-O: {best[0]}')