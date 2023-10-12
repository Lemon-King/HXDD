/*******************************************************************************
 * Copyright (c) 2015-2023 Matt Tropiano
 * This program and the accompanying materials are made available under the 
 * terms of the GNU Lesser Public License v2.1 which accompanies this 
 * distribution, and is available at
 * http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 ******************************************************************************/
package net.mtrop.doom.bsp;

import java.util.ArrayList;
import java.util.List;

import net.mtrop.doom.bsp.data.BSPNode;
import net.mtrop.doom.bsp.data.BSPSegment;
import net.mtrop.doom.bsp.data.BSPSubsector;

/**
 * BSP Tree Abstraction.
 * @author Matthew Tropiano
 */
public class BSPTree
{
	/** Nodes: List of Segments. */
	private List<BSPSegment> segments;
	/** Nodes: List of Subsectors. */
	private List<BSPSubsector> subsectors;
	/** Nodes: List of Nodes. */
	private List<BSPNode> nodes;
	
	public BSPTree()
	{
		segments = new ArrayList<BSPSegment>(1024);
		subsectors = new ArrayList<BSPSubsector>(1024);
		nodes = new ArrayList<BSPNode>(512);
	}

	/**
	 * @return the underlying list of segments.
	 */
	public List<BSPSegment> getSegments()
	{
		return segments;
	}

	/**
	 * Replaces the list of segments in the map.
	 * Input objects are copied to the underlying list.
	 * @param segments the new list of segments.
	 */
	public void setSegments(Iterable<BSPSegment> segments)
	{
		this.segments.clear();
		for (BSPSegment obj : segments)
			this.segments.add(obj);
	}

	/**
	 * Adds a segment to this map.
	 * @param segment the segment to add.
	 */
	public void addSegment(BSPSegment segment)
	{
		segments.add(segment);
	}

	/**
	 * @return the amount of segments in this map.
	 */
	public int getSegmentCount()
	{
		return segments.size();
	}

	/**
	 * Gets the segment at a specific index.
	 * @param i the desired index.
	 * @return the segment at the index, or null if the index is out of range.
	 */
	public BSPSegment getSegment(int i)
	{
		return segments.get(i);
	}

	/**
	 * @return the underlying list of subsectors.
	 */
	public List<BSPSubsector> getSubsectors()
	{
		return subsectors;
	}

	/**
	 * Replaces the list of subsectors in the map.
	 * Input objects are copied to the underlying list.
	 * @param subsectors the new list of subsectors.
	 */
	public void setSubsectors(Iterable<BSPSubsector> subsectors)
	{
		this.subsectors.clear();
		for (BSPSubsector obj : subsectors)
			this.subsectors.add(obj);
	}

	/**
	 * Adds a subsector to this map.
	 * @param subsector the subsector to add.
	 */
	public void addSubsector(BSPSubsector subsector)
	{
		subsectors.add(subsector);
	}

	/**
	 * @return the amount of subsectors in this map.
	 */
	public int getSubsectorCount()
	{
		return subsectors.size();
	}

	/**
	 * Gets the subsector at a specific index.
	 * @param i the desired index.
	 * @return the subsector at the index, or null if the index is out of range.
	 */
	public BSPSubsector getSubsector(int i)
	{
		return subsectors.get(i);
	}

	/**
	 * @return the underlying list of nodes.
	 */
	public List<BSPNode> getNodes()
	{
		return nodes;
	}

	/**
	 * Replaces the list of nodes in the map.
	 * Input objects are copied to the underlying list.
	 * @param nodes the new list of nodes.
	 */
	public void setNodes(Iterable<BSPNode> nodes)
	{
		this.nodes.clear();
		for (BSPNode obj : nodes)
			this.nodes.add(obj);
	}

	/**
	 * Adds a node to this map.
	 * @param node the node to add.
	 */
	public void addNode(BSPNode node)
	{
		nodes.add(node);
	}

	/**
	 * @return the amount of nodes in this map.
	 */
	public int getNodeCount()
	{
		return nodes.size();
	}

	/**
	 * Gets the node at a specific index.
	 * @param i the desired index.
	 * @return the node at the index, or null if the index is out of range.
	 */
	public BSPNode getNode(int i)
	{
		return nodes.get(i);
	}

}
